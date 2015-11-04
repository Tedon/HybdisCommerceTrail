//
// HYBCartController.m
// [y] hybris Platform
//
// Copyright (c) 2000-2014 hybris AG
// All rights reserved.
//
// This software is the confidential and proprietary information of hybris
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with hybris.
//

#import <ClassyLiveLayout/SHPAbstractView.h>
#import <CocoaLumberjack/DDLog.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import "HYBCartController.h"
#import "HYB2BService.h"
#import "HYBCartView.h"
#import "HYBCart.h"
#import "UIViewController+HYBBaseController.h"
#import "HYBConstants.h"
#import "NSUserDefaults+RMSaveCustomObject.h"
#import "HYBCartItemCellView.h"
#import "HYBCartItem.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "HYBProduct.h"
#import "HYBCustButton.h"

#import "HYBActivityIndicator.h"
#import "HYBButton.h"

#define TAG_ONE_ITEM_DELETION   12239658
#define TAG_MANY_ITEMS_DELETION 12239659


@interface HYBCartController ()
@property(nonatomic, strong)  HYBCart      *currentCart;
@property(nonatomic, strong)  NSArray      *cartItems;
@property(nonatomic, strong)  NSArray      *deletingItems;
@property(nonatomic, strong)  HYBCartView  *mainView;

@property(nonatomic, strong) id <HYBBackEndFacade> b2bService;

@property(nonatomic) NSInteger currentlyEditedCartItemPosition;
@end

@implementation HYBCartController

- (id)initWithBackEndService:(id <HYBBackEndFacade>)b2bService {
    
    if (self = [super init]) {
        self.b2bService = b2bService;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    if (!self.mainView) {
        self.mainView = [[HYBCartView alloc] init];
        self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.view = self.mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshCartFromServer];
    
    [self registerForCartChangeNotifications:@selector(loadCurrentCart) senderObject:self.b2bService];
    
    [self.mainView hideCart:YES];

    [self.mainView.continueShoppingButton addTarget:self action:@selector(continueShoppingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView.checkoutButton addTarget:self action:@selector(checkoutButtonPressed)];

    self.mainView.itemsTable.accessibilityIdentifier = @"ACCESS_CART_ITEMS";
    [self.mainView.itemsTable registerClass:[HYBCartItemCellView class] forCellReuseIdentifier:SIMPLE_CART_ITEM_CELL_ID];
    
    self.mainView.itemsTable.delegate = self;
    self.mainView.itemsTable.dataSource = self;
    
    self.mainView.itemsTable.allowsMultipleSelection = NO;
    
    //keyboard monitor
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(keyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    [center addObserver:self selector:@selector(keyboardDidHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    
    //batch delete interactions
    [self hideBatchDeletePanel];
    
    [self.mainView.batchToggleButton addTarget:self action:@selector(toggleBatchDeletePanel)];
    [self.mainView.batchSelectButton addTarget:self action:@selector(toggleBatchSelect)];
    [self.mainView.batchDeleteButton addTarget:self action:@selector(batchDelete)];
    
    [self refreshSelected];
}

- (void)toggleBatchDeletePanel {
    if (self.isBatchDeleting) return;
    
    if (self.mainView.batchDeletePanel.hidden == YES) {
        [self showBatchDeletePanel];
    } else {
        [self hideBatchDeletePanel];
    }
}

- (void)toggleBatchSelect {
    if ([[self.mainView.itemsTable indexPathsForSelectedRows] count] == 0) {
        //deselect all
        [self setAllRowsSelected:YES];
    } else {
        //select all
        [self setAllRowsSelected:NO];
    }
}

- (void)setAllRowsSelected:(BOOL)selected {
    for (NSInteger s = 0; s < self.mainView.itemsTable.numberOfSections; s++) {
        for (NSInteger r = 0; r < [self.mainView.itemsTable numberOfRowsInSection:s]; r++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:s];
            if (selected) {
                [self.mainView.itemsTable selectRowAtIndexPath:indexPath
                                                      animated:NO
                                                scrollPosition:UITableViewScrollPositionNone];
            } else {
                [self.mainView.itemsTable deselectRowAtIndexPath:indexPath
                                                        animated:NO];
            }
        }
    }
    [self refreshSelected];
}

- (void)showBatchDeletePanel {
    [self.mainView.itemsTable setEditing:NO animated:NO];
    self.mainView.itemsTable.allowsMultipleSelectionDuringEditing = YES;
    [self setAllRowsSelected:NO];
    [self.mainView.batchDeleteButton setHidden:YES];
    [self.mainView.batchDeletePanel setHidden:NO];
    [self.mainView.batchDeletePanel setAlpha:0];
    [UIView animateWithDuration:defaultAnimationDuration animations:^() {
        [self.mainView.batchDeletePanel setAlpha:1];
    }];
    [self.mainView.batchToggleButton setText:NSLocalizedString(@"batch_toggle_button_cancel", nil)];
    [self.mainView.itemsTable setEditing:YES animated:YES];
}

- (void)hideBatchDeletePanel {
    [self setAllRowsSelected:NO];
    [self refreshSelected];
    self.mainView.itemsTable.allowsMultipleSelectionDuringEditing = NO;
    [UIView animateWithDuration:defaultAnimationDuration animations:^() {
        [self.mainView.batchDeletePanel setAlpha:0];
    }
                     completion:^(BOOL done) {
                         [self.mainView.batchDeletePanel setHidden:YES];
                     }
     ];
    [self.mainView.batchToggleButton setText:NSLocalizedString(@"batch_toggle_button_edit", nil)];
    [self.mainView.itemsTable setEditing:NO animated:YES];
}

- (void)refreshSelected {
    
    if([[self.mainView.itemsTable indexPathsForSelectedRows] count] == 0) {
        [self.mainView.batchDeleteButton setHidden:YES];
        [self.mainView.batchSelectButton setText:NSLocalizedString(@"batch_select_all_button", nil)];
    } else {
        [self.mainView.batchDeleteButton setHidden:NO];
        [self.mainView.batchSelectButton setText:NSLocalizedString(@"batch_deselect_all_button", nil)];
    }
}

#pragma mark batch deletion loop
- (void)checkForBatchDeleteEnd {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.deletingItems];
    [tempArray removeLastObject];
    
    if([tempArray count] > 0) {
        //continue delete loop
        [self setDeletingItems:[NSArray arrayWithArray:tempArray]];
        [self deleteNextItem];
    } else {
        //no more item to delete, end loop
        [self setDeletingItems:[NSArray array]];
        [self batchDeleteDidEnd];
    }
}

- (void)deleteNextItem {
    [self deleteItemAtIndex:[self.deletingItems lastObject]];
}

- (void)batchDeleteDidEnd {
    [HYBActivityIndicator hide];
    
    [self showNotifyMessage:NSLocalizedString(@"cart_item_removal_items_removed", @"Items Removed!")];
    [self refreshCartFromServer];
    
    self.isBatchDeleting = NO;
}

- (void)deleteItemAtIndex:(NSIndexPath*)indexPath {
    [self.b2bService updateProductOnCurrentCartAmount:[NSString stringWithFormat:@"%ld", (long)indexPath.row]
                                                    mount:@0
                                               andExecute:^(HYBCart *cart, NSString *string) {
                                                   
                                                   [self checkForBatchDeleteEnd];
                                                   
                                               }];
}

- (void)startBatchDeleteLoop {
    self.isBatchDeleting = YES;
    
    [HYBActivityIndicator show];
    
    NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
    NSArray *sortedRows = [self.deletingItems sortedArrayUsingDescriptors:@[rowDescriptor]];
    [self setDeletingItems:[NSArray arrayWithArray:sortedRows]];
    
    self.currentlyEditedCartItemPosition = -1;
    [self deleteNextItem];
}

- (void)batchDelete {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cart_items_batch_removal_title", @"")
                                                        message:NSLocalizedString(@"cart_items_batch_removal_message", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                              otherButtonTitles:NSLocalizedString(@"cart_item_removal_popup_yes", @"Yes, I am sure"), nil];
        [alert setTag:TAG_MANY_ITEMS_DELETION];
        [alert show];
}

- (void)doBatchDelete {
    //save items to delete in another array, selected items array is wiped when the UI exits multi selection mode
    [self setDeletingItems:[NSArray arrayWithArray:[self.mainView.itemsTable indexPathsForSelectedRows]]];
    
    [self startBatchDeleteLoop];
    //TODO: add server side delete
    
    // Exit editing mode after the deletion.
    [self hideBatchDeletePanel];
}

#pragma mark vc life

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.view.findFirstResponder) [self.view.findFirstResponder resignFirstResponder];
}

- (void)checkoutButtonPressed {
    [self navigateToCheckout];
}

- (void)continueShoppingButtonPressed {
    [self navigateToCatalogAndToggleRightDrawer:YES triggerSearch:NO];
}

- (void)refreshCartFromServer {
    [self.b2bService retrieveCurrentCartAndExecute:^(HYBCart *cart, NSError *error) {
        [self setCurrentCart:cart];
        [self loadCurrentCart];
    }];
}

- (void)loadCurrentCart {
    HYBCart *cart = [self.b2bService currentCartFromCache];
    if (cart) {
        if ([cart isEmpty]) {
            self.isCartEmpty = YES;
            [self.mainView setCartToEmpty];
        } else {
            self.isCartEmpty = NO;
            [self.mainView hideCart:NO];
            [self.mainView setCartToNotEmpty];
        }
        
        if (!self.isCartEmpty) {
            NSString *totalLabel = [NSString stringWithFormat:NSLocalizedString(@"cart_label_total_items", nil), cart.totalUnitCount];
            [self.mainView.cartTotalLabel setText:totalLabel];
            
            [self.mainView.subTotalNumber setText:cart.subTotalFormatted];
            [self.mainView.taxNumber setText:cart.totalTaxFormatted];
            
            if(cart.deliveryCost) {
                [self.mainView.shippingLabel setHidden:NO];
                [self.mainView.shippingNumber setHidden:NO];
                
                [self.mainView.shippingNumber setText:cart.deliveryCost];
            } else {
                [self.mainView.shippingLabel setHidden:YES];
                [self.mainView.shippingNumber setHidden:YES];
            }
            
            [self.mainView.cartTotalNumber setText:cart.totalPriceFormatted];
            
            if (cart.orderDiscounts.intValue > 0) {
                [self.mainView.savingsNumber setText:cart.orderDiscountsFormattedValue];
                
                [self.mainView.discountsMessage setHidden:NO];
                [self.mainView.discountsMessage setText:cart.orderDiscountsMessage];
                
                [self.mainView.savingsNumber setHidden:NO];
                [self.mainView.savingsLabel setHidden:NO];
            } else {
                [self.mainView.discountsMessage setHidden:YES];
                [self.mainView.savingsLabel setHidden:YES];
                [self.mainView.savingsNumber setHidden:YES];
            }
        } else {
            [self.mainView hideCart:YES];
        }
        self.cartItems = cart.items;
        [self.mainView.itemsTable reloadData];
    } else {
        DDLogInfo(@"No cart is present in the user cache, a cart should have been created at the login.");
    }
}



- (CGFloat)calculateDrawerWidth {
    return [[UIScreen mainScreen] bounds].size.width * 0.8;
}

#pragma mark Cart Items Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return self.cartItems.count;
}

#pragma mark --> cellForRowAtIndexPath

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger currentRow = [indexPath row];
    
    HYBCartItem *item = [self.cartItems objectAtIndex:currentRow];
    HYBCartItemCellView *cell = (HYBCartItemCellView *) [table dequeueReusableCellWithIdentifier:SIMPLE_CART_ITEM_CELL_ID];
    
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"%@_%ld", @"ACCESS_CART_ITEM_CELL", (long)currentRow];
    
    if (item) {
        
        NSString *imageUrl = [item.product fullThumbnailURL];
        [self.b2bService loadImageByUrl:imageUrl block:^(UIImage *fetchedImage, NSError *error) {
            if (error) {
                DDLogError(@"Can not retrieve image for url: %@ reason: %@", imageUrl, [error localizedDescription]);
            } else {
                [cell loadWithItem:item.asDictionary withProductImage:fetchedImage];
                
                if (!table.editing) {
                    [cell.itemsInputTextfield setDelegate:self];
                    cell.itemsInputTextfield.tag = currentRow;
                    
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(productCellTapped:)];
                    tapRecognizer.numberOfTapsRequired = 1;
                    [cell.productDetailsTapArea addGestureRecognizer:tapRecognizer];
                    cell.productDetailsTapArea.tag = currentRow;
                }
                
                [cell setNeedsLayout];
                
                //access tags
                cell.productNameLabel.accessibilityIdentifier    = [NSString stringWithFormat:@"ACCESS_CART_ITEM_PRODUCT_TITLE_%ld", (long)currentRow];
                cell.productPriceLabel.accessibilityIdentifier   = [NSString stringWithFormat:@"ACCESS_CART_ITEM_PRODUCT_PRICE_%ld", (long)currentRow];
                cell.productPromoLabel.accessibilityIdentifier   = [NSString stringWithFormat:@"ACCESS_CART_ITEM_PRODUCT_PROMO_%ld", (long)currentRow];
                cell.totalPriceLabel.accessibilityIdentifier     = [NSString stringWithFormat:@"ACCESS_CART_ITEM_PRODUCT_TOTAL_PRICE_%ld", (long)currentRow];
                cell.itemsInputTextfield.accessibilityIdentifier = [NSString stringWithFormat:@"ACCESS_CART_ITEM_PRODUCT_QTY_%ld", (long)currentRow];
                cell.productImage.accessibilityIdentifier        = [NSString stringWithFormat:@"ACCESS_CART_ITEM_PRODUCT_IMAGE_%ld", (long)currentRow];
            }
        }];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isBatchDeleting) return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.currentlyEditedCartItemPosition = indexPath.row;
        [self deleteCurrentlyEditedItem];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HYBCartItem *item = (HYBCartItem*)[self.cartItems objectAtIndex:indexPath.row];
    if (item.discountMessage) return 100;
    
    return 75.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.mainView.itemsTable.editing) {
        [self refreshSelected];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mainView.itemsTable.editing) {
        [self refreshSelected];
    }
}

#pragma mark multiple selection helpers

- (void)productCellTapped:(UITapGestureRecognizer *)tapRecognizer {
    
    NSInteger taggedRow = tapRecognizer.view.tag;
    
    if (!self.mainView.itemsTable.editing) {
        HYBCartItemCellView *cell =  (HYBCartItemCellView *)[self.mainView.itemsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:taggedRow inSection:0]];
        
        NSAssert([cell hyb_isNotBlank], @"Cell was not found, it seems like the sender for this IBAction is not having a proper superview");
        
        [self.b2bService findProductById:cell.productCode withBlock:^(HYBProduct *product, NSError *error) {
            [self navigateToDetailControllerWithProduct:product.firstVariantCode toggleDrawer:YES];
        }];
    }
}

- (void)itemsQuantityChanged:(UITextField*)sender {
    
    NSInteger taggedRow = sender.tag;
    HYBCartItemCellView *cell =  (HYBCartItemCellView *)[self.mainView.itemsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:taggedRow inSection:0]];
    
    NSAssert([cell hyb_isNotBlank], @"Cell was not found, it seems like the sender for this IBAction is not having a proper superview");
    
    self.currentlyEditedCartItemPosition = [cell.cartItemPosition integerValue];
    
    NSNumber *amount = [[[NSNumberFormatter alloc] init] numberFromString:cell.itemsInputTextfield.text];
    if (amount.intValue == 0) {
        // starting the dialog for deletion, take a look at the UIAlertViewDelegate methods
        [self showAlertViewForItemDeletion];
    } else {
        if (amount) {
            [self.b2bService updateProductOnCurrentCartAmount:[NSString stringWithFormat:@"%ld", (long) self.currentlyEditedCartItemPosition] mount:amount andExecute:^(HYBCart *cart, NSString *string) {
                DDLogInfo(@"Product on cart was updated.");
                self.currentlyEditedCartItemPosition = -1;
            }];
        }
    }
}

#pragma mark alert for item deletion and its delegate

- (void)showAlertViewForItemDeletion {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cart_item_removal_popup_title", @"Item Removal")
                                                    message:NSLocalizedString(@"cart_item_removal_popup_message", @"Are you sure you would like to remove this item from the cart?")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                          otherButtonTitles:NSLocalizedString(@"cart_item_removal_popup_yes", @"Yes, I am sure"), nil];
    [alert setTag:TAG_ONE_ITEM_DELETION];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView tag] == TAG_ONE_ITEM_DELETION) {
        if (buttonIndex == 0) {
            DDLogInfo(@"Item Deletion Cancelled");
            HYBCartItem *item = [self.cartItems objectAtIndex:self.currentlyEditedCartItemPosition];
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.currentlyEditedCartItemPosition inSection:0];
            HYBCartItemCellView *cell = (HYBCartItemCellView *) [self.mainView.itemsTable cellForRowAtIndexPath:path];
            [cell.itemsInputTextfield setText:[item.quantity stringValue]];
        } else {
            DDLogVerbose(@"Item Deletion Confirmed");
            [self deleteCurrentlyEditedItem];
        }
    } else if ([alertView tag] == TAG_MANY_ITEMS_DELETION) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [self doBatchDelete];
        }
    }
}

- (void)deleteCurrentlyEditedItem {
    [self.b2bService updateProductOnCurrentCartAmount:[NSString stringWithFormat:@"%ld", (long) self.currentlyEditedCartItemPosition] mount:@0 andExecute:^(HYBCart *cart, NSString *string) {
        DDLogInfo(@"Product on cart was updated.");
        self.currentlyEditedCartItemPosition = -1;
        [self showNotifyMessage:NSLocalizedString(@"cart_item_removal_item_removed", @"Item Removed!")];
        [self setCurrentCart:cart];
        [self loadCurrentCart];
    }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    DDLogVerbose(@"Item Deletion Cancelled");
    HYBCartItem *item = [self.cartItems objectAtIndex:self.currentlyEditedCartItemPosition];
    HYBCartItemCellView *cell = (HYBCartItemCellView *) [self.mainView.itemsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentlyEditedCartItemPosition inSection:0]];
    [cell.itemsInputTextfield setText:[item.quantity stringValue]];
}


#pragma mark textfield delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.mainView.itemsTable.editing) return NO;
    if (self.isBatchDeleting) return NO;
    
    self.validAmount = NO;
    
    self.firstResponderOriginalValue = textField.text;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.validAmount) [self itemsQuantityChanged:textField];
    else textField.text = self.firstResponderOriginalValue;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.validAmount = YES;
    [textField resignFirstResponder];
    return NO;
}

@end