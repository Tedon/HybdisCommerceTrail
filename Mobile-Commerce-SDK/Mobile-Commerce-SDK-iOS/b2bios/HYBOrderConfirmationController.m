//
// HYBOrderConfirmationController.m
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


#import "HYBOrderConfirmationController.h"
#import "HYBOrderConfirmationView.h"
#import "HYBCart.h"
#import "HYBOrder.h"
#import "HYBCartItemCellView.h"
#import "HYBCartItem.h"
#import "HYBProduct.h"
#import "HYBAddress.h"
#import "HYBDeliveryMode.h"
#import "HYBButton.h"

@interface HYBOrderConfirmationController ()
@property(nonatomic, strong) HYBOrderConfirmationView *mainView;
@property(nonatomic, strong) HYBOrder *order;
@property(nonatomic, strong) NSArray *cartItems;
@end


@implementation HYBOrderConfirmationController

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService andOrder:(HYBOrder *)order {
    if (self = [super initWithBackEndService:b2bService]) {
        self.order = order;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];
    
    self.currentCart = [self.b2bService currentCartFromCache];
    self.cartItems = self.currentCart.items;
    
    //table setup
    
    self.mainView.itemsTable.accessibilityIdentifier = @"ACCESS_CART_ITEMS";
    
    [self.mainView.itemsTable registerClass:[HYBCartItemCellView class] forCellReuseIdentifier:SIMPLE_CART_ITEM_CELL_ID];
    
    self.mainView.itemsTable.delegate = self;
    self.mainView.itemsTable.dataSource = self;
    
    //buttons interactions
    [self.mainView.continueShoppingButton addTarget:self action:@selector(continueShopping) forControlEvents:UIControlEventTouchUpInside];

    self.mainView.continueShoppingButton.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_CONTINUE_BUTTON";
    
    [self.mainView.orderNumberLinkLabel setText:self.order.code];

    self.mainView.orderNumberLinkLabel.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_REVIEW_LINK";
    
    self.mainView.orderNumberLinkLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapLinkRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrderLink)];
    tapLinkRecognizer.numberOfTapsRequired = 1;
    [self.mainView.orderNumberLinkLabel addGestureRecognizer:tapLinkRecognizer];

    [self.mainView.emailDetailsLabel setText:[self currentEmailDetails]];
    self.mainView.emailDetailsLabel.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_EMAIL_COPY_TEXT";


    [self.mainView.deliveryAddressValue setText:self.order.deliveryAddress.formattedAddressBreakLines];
    [self.mainView.deliveryMethodValue  setText:self.order.deliveryMode.name];
    
    
    //order summary
    if(self.mainView.orderSummaryView) {
        
        if ([self.currentCart isEmpty]) {
            [self.mainView.orderSummaryView.itemCount setText:NSLocalizedString(@"cart_label_your_cart_is_empty", nil)];
        } else {
            NSString *totalLabel = [NSString stringWithFormat:NSLocalizedString(@"xx_items", nil), self.currentCart.totalUnitCount];
            [self.mainView.orderSummaryView.itemCount setText:totalLabel];
        }
        
        [self.mainView.orderSummaryView.subtotalValue setText:self.currentCart.subTotalFormatted];
        [self.mainView.orderSummaryView.taxValue setText:self.currentCart.totalTaxFormatted];
        
        [self.mainView.orderSummaryView.shippingValue setText:self.order.deliveryMode.formattedValue];
        
        [self.mainView.orderSummaryView.orderTotalValue setText:self.currentCart.totalPriceFormatted];
        
        if (self.currentCart.orderDiscounts.intValue > 0) {
            [self.mainView.orderSummaryView.savingsValue setText:self.currentCart.orderDiscountsFormattedValue];
            [self.mainView.orderSummaryView.savingsRecapTitle setText:self.currentCart.orderDiscountsMessage];
            
            [self.mainView.orderSummaryView.savingsRecapPanel setHidden:NO];
            [self.mainView.orderSummaryView.savingsPanel setHidden:NO];
        } else {
            [self.mainView.orderSummaryView.savingsRecapPanel setHidden:YES];
            [self.mainView.orderSummaryView.savingsPanel setHidden:YES];
        }
    }
    
    //TODO, please proceed here by retrieving cart values from self.order.cart like
    DDLogInfo(@"Cart total items in confirmation are %d", self.order.cart.totalItems.intValue);
}

- (void)continueShopping {
    DDLogInfo(@"Continue Shopping");
    [self navigateToCatalogAndToggleRightDrawer:NO triggerSearch:NO];
}

- (void)openOrderLink {
    DDLogInfo(@"openOrderLink");
}

#pragma mark utilities
- (NSString *)currentEmailDetails {
    return [NSString stringWithFormat:NSLocalizedString(@"postcheckout_email_details", nil), [[self b2bService] currentUserEmail]];
}

#pragma mark - Loading the shown product
- (void)loadView {
    [super loadView];
    if (!self.mainView) {
        self.mainView = [[HYBOrderConfirmationView alloc] init];
    }
    self.view = self.mainView;
}

#pragma mark Cart Items Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return self.cartItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger currentRow = [indexPath row];
    
    HYBCartItem *item = [self.cartItems objectAtIndex:currentRow];
    HYBCartItemCellView *cell = (HYBCartItemCellView *) [table dequeueReusableCellWithIdentifier:SIMPLE_CART_ITEM_CELL_ID];
    
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"%@_%ld", @"ACCESS_CART_ITEM_CELL", (long)currentRow];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (item) {
        NSString *imageUrl = [item.product fullThumbnailURL];
        [self.b2bService loadImageByUrl:imageUrl block:^(UIImage *fetchedImage, NSError *error) {
            if (error) {
                DDLogError(@"Can not retrieve image for url: %@ reason: %@", imageUrl, [error localizedDescription]);
            } else {
                [cell loadWithItem:item.asDictionary withProductImage:fetchedImage];
               
                cell.itemsInputTextfield.userInteractionEnabled = NO;
                cell.itemsInputTextfield.borderStyle = UITextBorderStyleNone;
                
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

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HYBCartItem *item = [self.cartItems objectAtIndex:indexPath.row];
    
    [self.b2bService findProductById:item.product.code withBlock:^(HYBProduct *product, NSError *error) {
        [self navigateToDetailControllerWithProduct:product.firstVariantCode toggleDrawer:NO];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HYBCartItem *item = (HYBCartItem*)[self.cartItems objectAtIndex:indexPath.row];
    if (item.discountMessage) return 100;
    
    return 75.0;
}

@end
