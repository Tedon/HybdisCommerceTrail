//
// HYBCatalogController.m
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

#import "HYBCatalogController.h"
#import "HYBProduct.h"
#import "HYBCategory.h"
#import "HYBListViewCell.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "HYBCart.h"
#import "HYBCatalogView.h"
#import "UIView+HYBBase.h"
#import "HYBCustButton.h"
#import "HYBActivityIndicator.h"
#import "HYBCollectionViewCell.h"
#import "HYBAppDelegate.h"
#import "HYB2BService.h"

@interface HYBCatalogController ()
@property(nonatomic) HYBCatalogView *mainView;
@property(nonatomic, copy) NSString *didYoumeanQuery;
@property(nonatomic) NSString *currentSearchQuery;

@end

@implementation HYBCatalogController

dispatch_queue_t backgroundDownloadQueue;

@synthesize currentCategoryId;

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService {
    
    if (self = [super initWithBackEndService:b2bService]) {
        
        backgroundDownloadQueue = dispatch_queue_create("backgroundDownloadQueue", 0);
        
        NSAssert(self.b2bService != nil, @"Provide a valid backEndService.");
        
        _products = [NSArray array];
        self.searchExpanded = NO;
        
        NSString *lastShownCatId = [[self.b2bService userStorage] objectForKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
        
        [self.b2bService findCategoriesWithBlock:^(NSArray *foundCategories, NSError *error) {
            HYBCategory *category = [[foundCategories firstObject] findCategoryByIdInsideTree:lastShownCatId];
            if (category == nil) {
                DDLogDebug(@"No category was given all products will be loaded.");
                [self loadProducts];
            } else {
                DDLogDebug(@"Products from category %@ will be loaded.", category.id);
                [self loadProductsByCategoryId:category.id];
            }
        }];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    if (!self.mainView) {
        self.mainView = [[HYBCatalogView alloc] init];
        self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    self.view = self.mainView;
    
    self.mainView.searchField.delegate = self;
    
    //table view
    self.mainView.productsTable.delegate = self;
    self.mainView.productsTable.dataSource = self;
    [self.mainView.productsTable registerClass:[HYBListViewCell class] forCellReuseIdentifier:@"HYBListViewCellID"];
    
    //grid view
    self.mainView.productsGrid.delegate = self;
    self.mainView.productsGrid.dataSource = self;
    
    [self.mainView.didYouMeanLabel addTarget:self action:@selector(didYoumeanPressed)];
    
    [self displayCurrentLayout];
}

- (void)continueSearch {
    [self doPerformSearch];
}

- (void)performSearch {
    self.currentSearchQuery = [self.mainView searchField].text;
    DDLogDebug(@"Searching for products by query %@ ...", self.currentSearchQuery);
    
    [self.b2bService resetPagination];
    [self setProducts:[NSArray array]];
    self.allItemsLoaded = NO;
    
    [self doPerformSearch];
}

- (void)doPerformSearch {
    self.currentSearchQuery = [self.mainView searchField].text;
    DDLogDebug(@"Searching for products by query %@ ...", self.currentSearchQuery);
    
    [HYBActivityIndicator show];
    
    [self.b2bService findProductsBySearchQuery:self.currentSearchQuery andExecute:^(NSArray *products, NSString *spellingSuggestion, NSError *error) {
        [HYBActivityIndicator hide];
        
        if (error) {
            DDLogError(@"Problems during the retrieval of the products from the web service: %@", [error localizedDescription]);
        } else {
            
            [self processNewProducts:products];
            
            if ([spellingSuggestion hyb_isNotBlank]) {
                self.didYoumeanQuery = spellingSuggestion;
                [self.mainView setSpellingLabelWithSuggestion:self.didYoumeanQuery];
                [self.mainView expandDidYouMean];
            } else {
                [self.mainView collapseSearchResult];
                [self.mainView collapseDidYouMean];
            }
            [self.mainView expandSearchResult];
            [self.mainView setResultsLabelWithOriginalQuery:self.currentSearchQuery foundResultsNumber:self.b2bService.totalSearchResults];
            [self checkProductsCount];
        }
    }];
}

- (void)didYoumeanPressed {
    [self.mainView.searchField setText:self.didYoumeanQuery];
    [self performSearch];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //keyboard monitor
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(keyboardDidShow:)
                               name:UIKeyboardDidShowNotification
                             object:nil];
    
    [notificationCenter addObserver:self selector:@selector(keyboardDidHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.blockScroll = YES;
    
    if (self.searchExpanded) {
        [self displaySearch];
        [self displayCurrentLayout];
    }
}


- (UIView *)loadingView {
    
    UIView *container = [[UIView alloc] init];
    
    UILabel *textLabel = [[UILabel alloc] init];
    
    UIActivityIndicatorView *spinner = nil;
    
    if (self.allItemsLoaded) {
        textLabel.text = NSLocalizedString(@"all_items_loaded", @"");
    } else {
        textLabel.text = NSLocalizedString(@"loading", @"");
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        [container addSubview:spinner];
    }
    
    textLabel.accessibilityIdentifier = @"ACCESS_CATALOG_LOADING_CELL";
    
    [textLabel sizeToFit];
    [container addSubview:textLabel];
    
    //geometry
    CGFloat totalWidth = textLabel.bounds.size.width;
    CGFloat totalHeight = textLabel.bounds.size.height;
    
    if (spinner) {
        CGFloat marge = 10.f;
        
        totalWidth += spinner.bounds.size.width + marge;
        if (spinner.bounds.size.height > totalHeight) totalHeight = spinner.bounds.size.height;
        
        [textLabel setCenter:CGPointMake((totalWidth + spinner.bounds.size.width + marge) / 2, totalHeight / 2)];
    }
    
    [container setFrame:CGRectMake(0, 0, totalWidth, totalHeight)];
    
    return container;
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int mod = 0;
    if (self.loading && !self.allItemsLoaded) mod = 1;
    
    return [self.products count] + mod;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.loading && indexPath.row == [self.products count]) {
        UITableViewCell *uniqueCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        
        UIView *loadingView = [self loadingView];
        
        [loadingView setCenter:CGPointMake(384, 50)];
        [uniqueCell.contentView addSubview:loadingView];
        
        return uniqueCell;
    }
    
    //default cell
    HYBListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYBListViewCellID"
                                                              forIndexPath:indexPath];
    
    
    if (indexPath.row >= [self.products count]) return cell;
    
    HYBProduct *prod = [self.products objectAtIndex:indexPath.row];
    
    //update cell only if needed
    if(!cell.productCodeLabel.text || ![cell.productCodeLabel.text isEqualToString:[prod code]]) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *cellAccessId = [NSString stringWithFormat:@"%@_%ld", @"ACCESS_CONTENT_CATALOG_LIST_CELL", (long)[indexPath row]];
        cell.accessibilityIdentifier = cellAccessId;
        [cell setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listCellTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.delegate = self;
        [cell.tapArea addGestureRecognizer:tapRecognizer];
        [cell.tapArea setTag:indexPath.row];
        
        cell.productNameLabel.text = [prod name];
        cell.productCodeLabel.text = [prod code];
        cell.priceLabel.text = [prod formattedPrice];
        
        cell.quantityInputField.text = @"1";
        cell.quantityInputField.delegate = self;
        
        [cell.quantityInputField addTarget:self action:@selector(updateTotalAmount:) forControlEvents:UIControlEventEditingChanged];
        cell.quantityInputField.returnKeyType = UIReturnKeyDone;
        
        cell.productNameLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_NAME", cellAccessId];
        cell.productCodeLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_NO", cellAccessId];
        cell.priceLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_PRICE", cellAccessId];
        cell.quantityInputField.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_QTY", cellAccessId];
        cell.addToCartButton.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_ATC", cellAccessId];
        cell.totalItemPrice.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_TOTAL", cellAccessId];
        
        cell.stockLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_STOCK", cellAccessId];
        
        NSString *stockLabelValue = @"";
        
        BOOL buttonEnabled = YES;
        
        if (prod.multidimensional) {
            [self setHiddenForAddToCartArea:cell toValue:YES];
        } else {
            [self setHiddenForAddToCartArea:cell toValue:NO];
            // stock info in the live view is present only for not multi-d products
            if (prod.isInStock && !prod.lowStock) {
                stockLabelValue = NSLocalizedString(@"product_list_in_stock", nil);
                cell.stockLabel.cas_styleClass = @"inStock";
            } else if (prod.lowStock) {
                stockLabelValue = [NSString stringWithFormat:NSLocalizedString(@"product_list_low_stock_number", nil), [prod.stock intValue]];
                cell.stockLabel.cas_styleClass = @"lowStock";
            } else if (!prod.isInStock) {
                buttonEnabled = NO;
                cell.stockLabel.cas_styleClass = @"outOfStock";
                stockLabelValue = NSLocalizedString(@"product_list_out_of_stock", @"out of stock");
            }
        }
        
        cell.stockLabel.text = stockLabelValue;
        
        [self calculateTotalsForCell:cell withProduct:prod];
        
        cell.addToCartButton.tag = indexPath.row;
        
        if (buttonEnabled) {
            [cell.addToCartButton addTarget:self
                                 action:@selector(addToCartPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
            
            cell.addToCartButton.alpha = 1.f;
        } else {
            [cell.addToCartButton removeTarget:self
                                        action:@selector(addToCartPressed:)
                              forControlEvents:UIControlEventTouchUpInside];
            
            cell.addToCartButton.alpha = .33;
        }
        
        cell.quantityInputField.tag = indexPath.row;
        
        cell.productIcon.alpha = 0;
        cell.productIcon.image = nil;
        
        dispatch_async(backgroundDownloadQueue, ^{
            [self loadImageForProduct:prod inCellAtIndexPath:indexPath];
        });
        
        cell.accessibilityIdentifier = [NSString stringWithFormat:@"%@_%@_%@_%ld", [self class], @"ProductList", @"Cell", (long)indexPath.row];
        
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //block initial table view scroll
    if (self.blockScroll) return;
    
    // UITableView only moves in one direction, y axis
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0) {        
        if (!self.allItemsLoaded) [self loadNextProducts];
    }
}

- (void)setHiddenForAddToCartArea:(HYBListViewCell *)cell toValue:(BOOL)value {
    [cell.addToCartButton setHidden:value];
    [cell.quantityInputField setHidden:value];
    [cell.totalItemPrice setHidden:value];
}

- (void)itemsQuantityChanged:(UITextField*)field andAddToCart:(BOOL)addToCart {
    
    NSInteger selectedIndex = field.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
    
    HYBListViewCell *cell = (HYBListViewCell *) [self.mainView.productsTable cellForRowAtIndexPath:indexPath];
    
    HYBProduct *product = [_products objectAtIndex:selectedIndex];
    [self calculateTotalsForCell:cell withProduct:product];

    NSAssert([cell hyb_isNotBlank], @"Cell was not found");
    
    if(addToCart) [self addProductToCartFromCell:cell selectedIndex:selectedIndex];
    
}

- (void)listCellTapped:(UITapGestureRecognizer*)sender {
    NSInteger index = [(UITapGestureRecognizer*)sender view].tag;
    [self openDetailPageForProductAtIndex:index];
}

- (void)openDetailPageForProductAtIndex:(NSInteger)index {
    HYBProduct *selectedProduct = [self.products objectAtIndex:index];
    [self navigateToDetailControllerWithProduct:selectedProduct.firstVariantCode toggleDrawer:NO];
}

- (void)calculateTotalsForCell:(HYBListViewCell *)cell withProduct:(HYBProduct *)prod {
    NSNumber *quantity = [[[NSNumberFormatter alloc] init] numberFromString:cell.quantityInputField.text];
    if (quantity && [[prod price] hyb_isNotBlank]) {
        CGFloat totalPrice = [[prod price] floatValue] * [cell.quantityInputField.text integerValue];
        NSString *totalPriceLabelValue = [[NSString alloc] initWithFormat:@"%@%.02f", prod.currencySign, totalPrice];
        [cell.totalItemPrice setText:totalPriceLabelValue];
        [cell setNeedsLayout];
    }
}

- (void)addToCartPressed:(id)sender {
    UIButton *addToCartButton = (UIButton *) sender;
    
    
    NSInteger selectedIndex = addToCartButton.tag;
    DDLogDebug(@"Add to cart pressed at row %ld", (long)selectedIndex);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    
    HYBListViewCell *cell = (HYBListViewCell *) [self.mainView.productsTable cellForRowAtIndexPath:indexPath];
    [self addProductToCartFromCell:cell selectedIndex:selectedIndex];

}

- (void)addProductToCartFromCell:(HYBListViewCell *)cell selectedIndex:(NSInteger)selectedIndex {
    UITextField *orderInputField = cell.quantityInputField;
    
    [orderInputField resignFirstResponder];
    
    HYBProduct *product = [_products objectAtIndex:selectedIndex];
    
    NSNumber *amount = [[[NSNumberFormatter alloc] init] numberFromString:orderInputField.text];
    
    if (amount) {
        
        DDLogVerbose(@"Adding product %@ in amount %d to cart ", product.code, amount.intValue);
        
        __weak typeof(self) weakSelf = self;
        
        [self.b2bService addProductToCurrentCart:product.firstVariantCode amount:amount block:^(HYBCart *cart, NSString *msg) {
                        
            if (cart == nil) {
                DDLogError(@"Product %@ not added to cart.", product.firstVariantCode);
            } else {
                orderInputField.text = @"1";
                [weakSelf calculateTotalsForCell:cell withProduct:product];
            }
            
            [weakSelf showNotifyMessage:msg];
        }];
    }
}


- (void)loadImageForProduct:(HYBProduct *)prod inCellAtIndexPath:(NSIndexPath*)indexPath {
    
    NSString *imageUrl = [prod fullThumbnailURL];
    
    [self.b2bService loadImageByUrl:imageUrl block:^(UIImage *fetchedImage, NSError *error) {
        if (error) {
            DDLogVerbose(@"Can not retrieve image for url: %@ reason: %@", imageUrl, [error localizedDescription]);
        }
        
        if(fetchedImage) {
            id cell = nil;
            UIImageView *cellImageView = nil;
            
            if([[self getDelegate] isGridView]) {
                cell = (HYBCollectionViewCell *)[self.mainView.productsGrid cellForItemAtIndexPath:indexPath];
                if(cell) cellImageView = [cell productImageView];
            } else {
                cell = (HYBListViewCell *)[self.mainView.productsTable cellForRowAtIndexPath:indexPath];
                if(cell) cellImageView = [cell productIcon];
            }
            
            if (cellImageView) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cellImageView.image = fetchedImage;
                    
                    NSString *cellAccessId = [NSString stringWithFormat:@"%@_%ld", @"ACCESS_CONTENT_CATALOG_LIST_CELL", (long)indexPath.row];
                    cellImageView.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_IMAGE", cellAccessId];
                    
                    [UIView animateWithDuration:defaultAnimationDuration animations:^() {
                        cellImageView.alpha = 1.f;
                    }];
                });
                
            }
        }
    }];
}


- (void)cacheCurrentCategoryId:(NSString *)newCatID {
    if (!currentCategoryId || ![currentCategoryId isEqualToString:newCatID]) {
        currentCategoryId = [NSString stringWithString:newCatID];
    }
}

#pragma mark loading methods

- (void)initialLoadProducts {
    [self.b2bService resetPagination];
    [self findCategories];
}

- (void)findCategories {
    NSString *lastShownCatId = [[self.b2bService userStorage] objectForKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
    
    [self.b2bService findCategoriesWithBlock:^(NSArray *foundCategories, NSError *error) {
        HYBCategory *category = [[foundCategories firstObject] findCategoryByIdInsideTree:lastShownCatId];
        
        if (category == nil) {
            DDLogDebug(@"No category was given all products will be loaded.");
            self.currentCategoryId = nil;
            [self loadNextProducts];
        } else {
            DDLogDebug(@"Products from category %@ will be loaded.", category.id);
            [self loadProductsByCategoryId:category.id];
        }
    }];
}

- (void)loadNextProducts {
    if (!self.loading) {
        self.loading = YES;
        [self forceReload];
        
        //small delay to allow ui to display loading indicator
        
        [self performSelector:@selector(doLoad) withObject:nil afterDelay:.2];
    }
}

- (void)doLoad {
    if ([self.currentSearchQuery hyb_isNotBlank]) {
        [self continueSearch];
    } else {
        if (currentCategoryId) {
            [self loadProductsByCategoryId:currentCategoryId];
        } else {
            [self loadProducts];
        }
    }
}

- (void)loadBaseProductsByCategoryId:(NSString *)categoryId {
    
    [self.b2bService resetPagination];
    
    self.products = [NSArray array];
    self.allItemsLoaded = NO;
    self.loading = YES;
    if(self.searchExpanded){
        [self.mainView closeAllSearchPanels];
    }
    [self loadProductsByCategoryId:categoryId];
}

- (void)loadProductsByCategoryId:(NSString *)categoryId {
    
    [self cacheCurrentCategoryId:categoryId];
    
    DDLogDebug(@"Loading products for category %@", currentCategoryId);
    
    [self.b2bService findProductsByCategoryId:currentCategoryId
                                    withBlock:^(NSArray *products, NSError *error) {
                                        if (error) {
                                            DDLogError(@"Problems during the retrieval of the products from the web service: %@", [error localizedDescription]);
                                        } else {
                                            [self processNewProducts:products];
                                        }
                                    }];
}

- (void)loadProducts {
    
    [self.b2bService findProductsWithBlock:^(NSArray *products, NSError *error) {
        
        if (error) {
            DDLogError(@"Problems during the retrieval of the products from the web service: %@", [error localizedDescription]);
        } else {
            [self processNewProducts:products];
        }
    }];
}

- (void)checkProductsCount {
    if ([self.products count] == 0) {
        NSString *msg = NSLocalizedString(@"catalog_no_products_found_title", nil);
        [self showNotifyMessage:msg];
    }
}

/**
 *  refresh ui with new products added by scrolling down
 *
 *  @param newProducts array of products
 */
- (void)processNewProducts:(NSArray *)newProducts {
    
    self.loading = NO;
    self.blockScroll = NO;
    
    BOOL forceReload = NO;
    
    if (!newProducts || [newProducts count] == 0) {
        self.allItemsLoaded = YES;
        
        if ([self.b2bService currentPage] == 0 && [self.products count] == 0) {
            DDLogDebug(@"empty category");
            NSString *msg = NSLocalizedString(@"catalog_no_products_found_title", nil);
            [self showNotifyMessage:msg];
            
            forceReload = YES;
        }
    } else {
        if ([newProducts count] < [self.b2bService pageSize]) {
            self.allItemsLoaded = YES;
        }
        
        if ([newProducts count] > 0 && [self.products count] == 0) {
            DDLogDebug(@"new Category or new Search ");
            forceReload = YES;
        }
    }
    
    if (forceReload) {
        self.products = [NSArray arrayWithArray:newProducts];
        [self forceReload];
        [self.b2bService nextPage];
    } else {
        
        //debounce products (prevent adding same product coming from cache and server)
        
        //1- keep only products to add in an array
        NSMutableArray *tempArray = [NSMutableArray array];
        
        BOOL add = YES;
        
        for (HYBProduct *newProduct in newProducts) {
            add = YES;
            for (HYBProduct *oldProduct in self.products) {
                if ([newProduct.code isEqualToString:oldProduct.code]) {
                    add = NO;
                    break;
                }
            }
            
            if (add) {
                [tempArray addObject:newProduct];
            }
        }
        
        //if we have any new result to add
        if ([tempArray count] > 0) {
            
            //2 - create indexPaths array
            NSMutableArray *tmpIndexPaths = [NSMutableArray array];
            int origin = (int)[self.products count]-1;
            if (origin < 0) origin = 0;
            
            for (int i = 0; i < [tempArray count]; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i+origin inSection:0];
                [tmpIndexPaths addObject:indexPath];
            }
            
            NSArray *indexPaths = [NSArray arrayWithArray:tmpIndexPaths];
            
            //3 - join data
            NSArray *finalArray = [self.products arrayByAddingObjectsFromArray:tempArray];
            
            self.products = [NSArray arrayWithArray:finalArray];
            
            // - insert new cells
            
            if (indexPaths && [indexPaths count] > 0) {
                
                if([[self getDelegate] isGridView]) {
                    [self.mainView.productsGrid performBatchUpdates:^{
                        [self.mainView.productsGrid insertItemsAtIndexPaths:indexPaths];
                    }
                                                         completion:nil];
                } else {
                    [self.mainView.productsTable reloadData];
                }
            }
            
            [self.b2bService nextPage];
        }
    }
}


//insertItemsAtIndexPaths
#pragma mark display layout

/**
 *  reload all data in grid or tableview
 */
- (void)forceReload {
    
    [self displayCurrentLayout];
    
    if ([self getDelegate].isGridView) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.mainView.productsGrid reloadData];
        });
    } else {
        [self.mainView.productsTable reloadData];
    }
}

/**
 *  adapt ui according to user grid vs list layout
 */
-(void)displayCurrentLayout {
    
    BOOL localIsGridView = [self getDelegate].isGridView;
    
    [self.mainView.productsGrid  setHidden:!localIsGridView];
    [self.mainView.productsTable setHidden:localIsGridView];
    
    if(localIsGridView) {
        [self.mainView.productsTable replaceStyle:@"swapExpanded"   withStyle:@"swapCollapsed"];
        [self.mainView.productsGrid  replaceStyle:@"swapCollapsed"  withStyle:@"swapExpanded"];
    } else {
        [self.mainView.productsTable replaceStyle:@"swapCollapsed"  withStyle:@"swapExpanded"];
        [self.mainView.productsGrid  replaceStyle:@"swapExpanded"   withStyle:@"swapCollapsed"];
    }
}

#pragma mark text field delegate manage editing

- (void)updateTotalAmount:(id)sender {
    [self itemsQuantityChanged:sender andAddToCart:NO];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.firstResponderOriginalValue = textField.text;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (!textField.text || textField.text.length <= 0) {
        textField.text = self.firstResponderOriginalValue;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.mainView.searchField) {
        [self performSearch];
    } else {
        [self itemsQuantityChanged:textField andAddToCart:YES];
    }
    [textField resignFirstResponder];
    return NO;
}

- (void)clearQuery {
    self.currentSearchQuery = nil;
    [[self mainView] collapseSearch];
    [self.mainView.searchField resignFirstResponder];
    self.allItemsLoaded = NO;
    self.searchExpanded = NO;
}

- (void)triggerSearch {
    DDLogDebug(@"Trigger search...");
    if (self.searchExpanded) {
        [self.mainView closeAllSearchPanels];
        self.searchExpanded = NO;
        self.currentSearchQuery = nil;
    } else {
        self.searchExpanded = YES;
        [self displaySearch];
    }
    [self displayCurrentLayout];
}

- (void)displaySearch {
    if ([self.currentSearchQuery hyb_isNotBlank]) {
        [self.mainView.searchField setText:self.currentSearchQuery];
    }
    [[self mainView] expandSearch];
    [self.mainView.searchField becomeFirstResponder];
}

#pragma mark grid view delegates

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    CGFloat marge = 10.f;
    return UIEdgeInsetsMake(marge, marge, marge, marge);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.products count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(246, 300);
}

- (HYBCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                     cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HYBCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCellId" forIndexPath:indexPath];
    NSString *cellAccessId = [NSString stringWithFormat:@"%@_%ld", @"ACCESS_CONTENT_CATALOG_LIST_GRID", (long)[indexPath row]];
    cell.accessibilityIdentifier = cellAccessId;
    
    HYBProduct *product = [self.products objectAtIndex:indexPath.row];
    
    //security
    if (indexPath.row >= [self.products count]) return cell;
    
    //update cell only if needed
    if(!cell.productCodeLabel.text || ![cell.productCodeLabel.text isEqualToString:product.code]) {
        cell.productNameLabel.text  = product.name;
        cell.productCodeLabel.text  = product.code;
        cell.productPriceLabel.text = product.priceRange;
        
        cell.productNameLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_NAME", cellAccessId];
        cell.productCodeLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_NO", cellAccessId];
        cell.productPriceLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%@_PRODUCT_PRICE", cellAccessId];
        
        cell.productImageView.alpha = 0;
        cell.productImageView.image = nil;
        
        dispatch_async(backgroundDownloadQueue, ^{
            [self loadImageForProduct:product inCellAtIndexPath:indexPath];
        });
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self openDetailPageForProductAtIndex:indexPath.row];
}

@end
