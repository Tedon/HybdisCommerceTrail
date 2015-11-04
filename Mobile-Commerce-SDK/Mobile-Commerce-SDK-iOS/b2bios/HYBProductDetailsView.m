//
// HYBProductDetailsView.m
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

#import <BlocksKit/NSArray+BlocksKit.h>
#import "HYBProductDetailsView.h"
#import <ColorUtils/ColorUtils.h>
#import <ClassyLiveLayout/UIView+ClassyLayoutProperties.h>
#import "UIView+CASAdditions.h"
#import "HYBProduct.h"
#import "HYBButton.h"
#import "HYBConstants.h"
#import "UIView+HYBBase.h"
#import "UILabel+HYBLabel.h"
#import "UIButton+HYBButton.h"
#import "UIView+BlocksKit.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "HYBProductVariantOption.h"
#import "HYBZoomView.h"
#import "UIView+ClassyLayoutProperties.h"

#define TAG_PRODUCT_DETAILS_TITLE       35600
#define TAG_PRODUCT_DETAILS_CONTENT     35601

#define TAG_PRODUCT_DELIVERY_TITLE      35602
#define TAG_PRODUCT_DELIVERY_CONTENT    35603

#define TAG_PRODUCT_REVIEWS_TITLE       35604
#define TAG_PRODUCT_REVIEWS_CONTENT     35605

int tag_offset = 55500;

CGFloat defaultIndentation = 20;

CGFloat variableHeight;



@interface HYBProductDetailsView ()

@property(nonatomic)  UITextView     *summary;
@property(nonatomic)  UIView         *variantValuePickerPanel;
@property(nonatomic)  UIPickerView   *variantValuePicker;
@property(nonatomic)  UILabel        *productNameLabel;
@property(nonatomic)  UILabel        *isInStockLabel;
@property(nonatomic)  HYBProduct     *product;
@property(nonatomic)  UILabel        *productCodeLabel;
@property(nonatomic)  UILabel        *productPriceLabel;
@property(nonatomic)  UIView         *volumePricesPanel;
@property(nonatomic)  UIView         *variantButtonsPanel;
@property(nonatomic)  UITableView    *tabsTable;
@property(nonatomic)  UIView         *priceMatrix;
@property(nonatomic)  NSMutableArray *variantSelectionButtons;
@property(nonatomic)  NSArray        *currentVariantsMatrix;
@property(nonatomic)  NSArray        *tableContent;
@property(nonatomic)  NSArray        *visibleTableContent;
@property(nonatomic)  NSArray        *sortedImagesArray;
@property(nonatomic)  BOOL           isUp;
@property(nonatomic)  BOOL           isPricingOpen;

@property(nonatomic)  NSMutableDictionary        *tableCellsCacheDict;

@end



@implementation HYBProductDetailsView

@synthesize selectedVariantsDict;

- (id)init {
    if(self = [super init]) {
        [self setSelectedVariantsDict:[NSDictionary dictionary]];

        self.isUp = NO;
    }
    return self;
}

#pragma Global View Setup

/**
 *  generate view layout
 */
- (void)addSubviews {
    DDLogDebug(@"addSubviews");
    
    
    self.masterScrollView = [[UIScrollView alloc] initScrollViewWithStyleClassId:@"masterScrollView"];
    self.masterScrollView.userInteractionEnabled = YES;
    
    self.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS";
    
    self.titlePanel = [[UIView alloc] initWithStyleClassId:@"panel titlePanel"];
    
    self.closeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Close_Icon.png"]];
    self.closeIcon.cas_styleClass = @"closeIcon";
    self.closeIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.closeIcon.userInteractionEnabled = YES;
    self.closeIcon.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_BACK";
    
    self.titleDetailsPanel = [[UIView alloc] initWithStyleClassId:@"panel titleDetailsPanel"];
    
    [self.titlePanel addSubview:self.closeIcon];
    [self.titlePanel addSubview:self.titleDetailsPanel];
    
    self.productNameLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel name alignLeft" text:@""];
    self.productNameLabel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_TITLE";
    
    self.productCodeLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel code alignLeft" text:@""];
    self.productCodeLabel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_CODE";
    
    [self.titleDetailsPanel addSubview:self.productNameLabel];
    [self.titleDetailsPanel addSubview:self.productCodeLabel];
    
    self.imagesScrollView = [[UIScrollView alloc] init];
    self.imagesScrollView.cas_styleClass = @"imagesScroll";
    
    self.imagesScrollControl = [[UIPageControl alloc] init];
    self.imagesScrollControl.cas_styleClass = @"imagesScrollControl";
    
    self.summary = [[UITextView alloc] init];
    [self.summary setEditable:NO];
    [self.summary setTextAlignment:NSTextAlignmentLeft];
    self.summary.cas_styleClass = @"summary";
    self.summary.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_SUMMARY";
    
    self.volumePricesPanel = [[UIView alloc] initWithStyleClassId:@"panel collapsed"];
    self.volumePricesPanel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_VOLUME_PRICING_CLOSED";
    
    self.priceMatrix = [[UIView alloc] initWithStyleClassId:@"collapsedPriceMatrix"];
    
    self.variantButtonsPanel = [[UIView alloc] initWithStyleClassId:@"panel"];
    
    self.quantityInputPanel = [[UIView alloc] initWithStyleClassId:@"panel"];
    
    self.addToCartButton = [[HYBButton alloc] initWithStyleClassId:@"primaryButton addToCartButton"
                                                             title:NSLocalizedString(@"product_details_buttons_add_to_cart", nil)];
    self.addToCartButton.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_ATC";
    
    self.tabsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    self.tabsTable.cas_styleClass = @"tabsTable";
    
    [self addSubview:self.titlePanel];
    
    NSArray *verticalLayoutViews = @[ self.imagesScrollView,
                                      self.imagesScrollControl, self.volumePricesPanel, self.priceMatrix, self.summary,
                                      self.variantButtonsPanel, self.quantityInputPanel, self.addToCartButton, self.tabsTable];
    
    [verticalLayoutViews bk_each:^(UIView *subView) {
        [self.masterScrollView addSubview:subView];
    }];
    
    [self addSubview:self.masterScrollView];
    
    // variant selection done button creation, will be shown in the variants popup
    _variantSelectionCancelButton = [[HYBButton alloc] initWithPosition:CGPointZero
                                                      appendAtSuperView:_variantValuePickerPanel
                                                                  title:nil];
    [_variantSelectionCancelButton layoutAs:HYBButtonTypePrimary];
    
    _variantSelectionDoneButton = [[HYBButton alloc] initWithPosition:CGPointZero
                                                    appendAtSuperView:_variantValuePickerPanel
                                                                title:nil];
    [_variantSelectionDoneButton layoutAs:HYBButtonTypePrimary];
    
}

-(void)updateMasterScrollViewContentSize {
    CGRect baseRect = self.masterScrollView.frame;
    
    CGFloat tableOriginY = self.tabsTable.frame.origin.y+baseRect.origin.y;
    CGFloat tableOverFlow = tableOriginY+variableHeight;
    
    CGFloat marge = 12.f;
    
    CGFloat width  = baseRect.size.width;
    CGFloat height = tableOverFlow + marge;
    
    [self.masterScrollView setContentSize:CGSizeMake(width, height)];
    
    CGRect visibleTabFrame = CGRectMake(0, tableOriginY, width, variableHeight+marge);
    [self.masterScrollView scrollRectToVisible:visibleTabFrame animated:YES];
}

- (void)defineLayout {
    
}

- (void)updateConstraints {
    DDLogDebug(@"Update constrains");
    [super updateConstraints];
    
    [self.titleDetailsPanel layoutSubviewsVertically];
    [self.titlePanel layoutSubviewsHorizontally];
    [self.volumePricesPanel layoutSubviewsHorizontally];
    [self.variantButtonsPanel layoutSubviewsHorizontally];
    [self.quantityInputPanel layoutSubviewsHorizontally];
    
    [self.priceMatrix layoutSubviewsVertically];
    [self.priceMatrix bk_eachSubview:^(UIView *subview) {
        [subview layoutSubviewsHorizontally];
    }];
    
    [self.masterScrollView layoutSubviewsVertically];
    
    [self layoutSubviewsVertically];
    
}

#pragma mark Product Load

- (void)loadImagesInView:(NSArray *)productImages {
    
    NSArray *sortedArray = [productImages sortedArrayUsingComparator:^NSComparisonResult(UIImage *image1, UIImage *image2){
        NSNumber *sizeImage1 = [NSNumber numberWithFloat:(image1.size.width * image1.size.height)];
        NSNumber *sizeImage2 = [NSNumber numberWithFloat:(image2.size.width * image2.size.height)];
        return ([sizeImage1 compare:sizeImage2] == NSOrderedAscending);
    }];
    
    DDLogDebug(@"Rendering %lu  images inside the scroll view of detail page", (unsigned long)sortedArray.count);
    NSAssert(self.imagesScrollControl != nil, @"Images scroll control must be present.");
    
    self.imagesScrollControl.currentPage = 0;
    self.imagesScrollControl.numberOfPages = [sortedArray count];
    self.imagesScrollControl.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_IMAGE_INDICATOR";
    
    CGSize pagesScrollViewSize = self.imagesScrollView.frame.size;
    
    self.imagesScrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * sortedArray.count,
                                                   pagesScrollViewSize.height);
    
    
    
    if (sortedArray != nil) {
        
        _sortedImagesArray = [NSArray arrayWithArray:sortedArray];
        
        for (int pageIndex = 0; pageIndex < sortedArray.count; pageIndex++) {
            
            int tagIndex = pageIndex+tag_offset;
            
            //debounce, only keep the newest image
            UIView *oldPageView = [self.imagesScrollView viewWithTag:tagIndex];
            if(oldPageView) [oldPageView removeFromSuperview];
            
            UIImageView *pageView = [[UIImageView alloc] initWithFrame:self.imagesScrollView.bounds];
            UIImage *image = [sortedArray objectAtIndex:pageIndex];
            
            if (image.size.width > self.imagesScrollView.bounds.size.width || image.size.height > self.imagesScrollView.bounds.size.height) {
                pageView.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                pageView.contentMode = UIViewContentModeCenter;
            }

            [pageView setImage:image];
            
            NSString *imageAccessId = [NSString stringWithFormat:@"%@_%d", @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_IMAGE", pageIndex];
            pageView.accessibilityIdentifier = imageAccessId;
            
            pageView.center = CGPointMake(pagesScrollViewSize.width/2+pagesScrollViewSize.width*pageIndex, pagesScrollViewSize.height/2);
            
            pageView.tag = tagIndex;
            
            [self.imagesScrollView addSubview:pageView];
            
            [pageView setUserInteractionEnabled:YES];
            
            //zoom interaction
            UITapGestureRecognizer *zoomTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openZoomForProductImageAtIndex:)];
            
            [pageView addGestureRecognizer:zoomTap];
            
        }
    }
}


- (void)openZoomForProductImageAtIndex:(UITapGestureRecognizer*)sender {
    
    int index = (int)sender.view.tag - tag_offset;
    
    if(index < [_sortedImagesArray count]) {
        UIImage *image = [_sortedImagesArray objectAtIndex:index];
        
        HYBZoomView *zoomView = [HYBZoomView zoomViewWithFrame:self.frame andImage:image];
        zoomView.alpha = 0.f;
        [self addSubview:zoomView];
        
        [UIView animateWithDuration:defaultAnimationDuration
                         animations:^() {
                             zoomView.alpha = 1.f;
                         }];
        
    }
}

- (void)loadProductDetails:(HYBProduct *)product {
    DDLogDebug(@"Loading product details for product %@", product.code);
    self.product = product;
    
    self.tableCellsCacheDict = [NSMutableDictionary dictionary];
    
    self.tableContent = [NSArray arrayWithObjects:
                         
                         //first cell title
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"product_details_details", @"Details"),@"content",
                          [NSNumber numberWithInt:TAG_PRODUCT_DETAILS_TITLE],@"tag",
                          @"title",@"status",
                          @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_DETAILS_TITLE",@"accessId",
                          nil],
                         
                         //first cell content
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          [self.product desc],@"content",
                          [NSNumber numberWithInt:TAG_PRODUCT_DETAILS_CONTENT],@"tag",
                          @"closed",@"status",
                          @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_DETAILS_CONTENT",@"accessId",
                          nil],
                         
                         //second cell title
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"product_details_delivery", @"Delivery"),@"content",
                          [NSNumber numberWithInt:TAG_PRODUCT_DELIVERY_TITLE],@"tag",
                          @"title",@"status",
                          @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_DELIVERY_TITLE",@"accessId",
                          nil],
                         
                         //second cell content
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          [self.product deliveryDetails],@"content",
                          [NSNumber numberWithInt:TAG_PRODUCT_DELIVERY_CONTENT],@"tag",
                          @"closed",@"status",
                          @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_DELIVERY_CONTENT",@"accessId",
                          nil],
                         
                         /*
                          //third cell title
                          [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"product_details_reviews", @"Reviews"),@"content",
                          [NSNumber numberWithInt:TAG_PRODUCT_REVIEWS_TITLE],@"tag",
                          @"title",@"status",
                          @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_REVIEWS_TITLE",@"accessId",
                          nil],
                          
                          //third cell content
                          [NSDictionary dictionaryWithObjectsAndKeys:
                          [self.product reviews],@"content",
                          [NSNumber numberWithInt:TAG_PRODUCT_REVIEWS_CONTENT],@"tag",
                          @"closed",@"status",
                          @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_REVIEWS_CONTENT",@"accessId",
                          nil],
                          */
                         
                         nil];
    
    
    [self.productNameLabel setText:[product name]];
    [self.summary setText:[product desc]];
    [self.productCodeLabel setText:[product code]];
    [self.summary setText:product.summary];
    
    
    [self buildQuantityInputPanel];
    [self calculateTotalPrice];
    [self buildTabsTable];
    [self buildUpVariants];
    [self configPricingPanel];
}

#pragma mark table sizing

- (void)updateVisibleTableContent {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSDictionary *dict in self.tableContent) {
        if([dict[@"status"]isEqualToString:@"title"] || [dict[@"status"]isEqualToString:@"open"]) {
            [tempArray addObject:dict];
        }
    }
    
    self.visibleTableContent = [NSArray arrayWithArray:tempArray];
    
    [self.tabsTable reloadData];
    
    [self resizeTable];
}

- (void)resizeTable {
    
    variableHeight = 0.f;
    
    for(int i = 0; i < [self.visibleTableContent count]; i++) {
        CGFloat cellHeight = [self tableView:self.tabsTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        variableHeight += cellHeight;
    }
    
    CGRect oldRect = self.tabsTable.frame;
    CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.size.width, variableHeight);
    
    self.tabsTable.frame = newRect;
    
    UIView *tabView =(UIView*)self.tabsTable;
    tabView.cas_size = CGSizeMake(self.tabsTable.frame.size.width, variableHeight);
    
    [self updateConstraints];
    
    [self updateMasterScrollViewContentSize];
}

#pragma mark - Pricing Labels and Panels

- (void)buildQuantityInputPanel {
    [self.quantityInputPanel removeAllSubViews];
    
    NSString *stockLabel = [NSString stringWithFormat:NSLocalizedString(@""
                                                                        "Avalability: %d", nil), [self.product.stock integerValue]];
    self.availabilityLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel availabilityLabel"
                                                              text:stockLabel];
    self.availabilityLabel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_STOCK";
    
    [self.availabilityLabel setText:stockLabel];
    
    if (self.product.lowStock) {
        self.isInStockLabel.textColor = [UIColor redColor];
    }
    
    [self.quantityInputPanel addSubview:self.availabilityLabel];
    
    self.quantityLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel quantityLabel"
                                                          text:@"QTY"];
    self.quantityLabel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_QTY";
    [self.quantityInputPanel addSubview:self.quantityLabel];
    
    self.quantityInputField = [[UITextField alloc] init];
    self.quantityInputField.cas_styleClass = @"secondaryTextfield quantityInputField";
    [self.quantityInputField setText:@"1"];
    [self.quantityInputField setKeyboardType:UIKeyboardTypeNumberPad];
    self.quantityInputField.borderStyle = UITextBorderStyleRoundedRect;
    self.quantityInputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.quantityInputField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.quantityInputField addTarget:self action:@selector(itemsQuantityChanged) forControlEvents:UIControlEventEditingChanged];
    
    self.quantityInputField.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_AMT";
    self.quantityInputField.delegate = self;
    
    [self.quantityInputPanel addSubview:self.quantityInputField];
    
    
    self.totalItemPrice = [[UILabel alloc] initWithStyleClassId:@"textLabel totalItemPrice"
                                                           text:@"0"];
    self.totalItemPrice.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_TOTAL";
    [self.quantityInputPanel addSubview:self.totalItemPrice];
    
    [self calculateTotalPrice];
}

- (void)itemsQuantityChanged {
    [self calculateTotalPrice];
}

- (void)configPricingPanel {
    [self.volumePricesPanel removeAllSubViews];
    
    self.productPriceLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel productPriceLabel" text:[_product formattedPrice]];
    self.productPriceLabel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_PRICE";
    
    [self.volumePricesPanel addSubview:self.productPriceLabel];
    
    if ([self.product isVolumePricingPresent]) {
        self.productPriceLabelSeparator = [[UILabel alloc] initWithStyleClassId:@"textLabel productPriceLabelSeparator" text:@"|"];
        
        self.volumePricingButton = [[UIButton alloc] initWithStyleClassId:@"dropdownButton"
                                                                    title:NSLocalizedString(@"product_details_volume_pricing", nil)];
        [self.volumePricingButton layoutAsDropdownButton];
        
        [self.volumePricingButton addTarget:self action:@selector(showOrHideVolumePricing) forControlEvents:UIControlEventTouchUpInside];
        
        [self.volumePricesPanel addSubview:self.productPriceLabelSeparator];
        [self.volumePricesPanel addSubview:self.volumePricingButton];
        
        [self.priceMatrix removeAllSubViews];
        
        int rowsNumber = 0;
        if (_product.volumePricingData.count % 2 == 0) {
            rowsNumber = (int)(_product.volumePricingData.count) / 2;
        } else {
            rowsNumber = (int)(_product.volumePricingData.count + 1) / 2;
        }
        int currentVolumePricingItemIndex = 0;
        
        for (int currentRow = 0; currentRow < rowsNumber; ++currentRow) {
            UIView *panel = [[UIView alloc] initWithStyleClassId:@"volumePricingPanelRow"];
            for (int currentColumn = 0; currentColumn < 5; ++currentColumn) {
                
                UIView *cell = nil;
                NSString *labelText = nil;
                
                BOOL isPricingRow = currentColumn == 1 || currentColumn == 4;
                BOOL isHeaderRow = currentRow == 0;
                
                if (isHeaderRow) {
                    if (isPricingRow) {
                        labelText = [NSString stringWithFormat:@"Price"];
                        cell = [[UILabel alloc] initWithStyleClassId:@"volumePricingCellLabel" text:labelText];
                    } else if (currentColumn == 2) {
                        cell = [[UIView alloc] initWithStyleClassId:@"verticalSeparator"];
                    } else {
                        labelText = [NSString stringWithFormat:@"QTY"];
                        cell = [[UILabel alloc] initWithStyleClassId:@"volumePricingCellLabel" text:labelText];
                    }
                } else {
                    if (currentColumn > 2) {
                        //second table row and we exclude the header and subtract the header from the total rows amount
                        currentVolumePricingItemIndex = currentRow - 1 + (rowsNumber - 1);
                    } else {
                        // first table row, subtract the header row
                        currentVolumePricingItemIndex = currentRow - 1;
                    }
                    if (isPricingRow) {
                        labelText = [_product pricingValueForItemAtIndex:currentVolumePricingItemIndex];
                        cell = [[UILabel alloc] initWithStyleClassId:@"volumePricingCellLabel" text:labelText];
                    } else if (currentColumn == 2) {
                        cell = [[UIView alloc] initWithStyleClassId:@"verticalSeparator"];
                    } else {
                        labelText = [_product quantityValueForItemAtIndex:currentVolumePricingItemIndex];
                        cell = [[UILabel alloc] initWithStyleClassId:@"volumePricingCellLabel" text:labelText];
                    }
                }
                [panel addSubview:cell];
            }
            [self.priceMatrix addSubview:panel];
        }
        [[self.priceMatrix subviews] bk_each:^(UIView *view) {
            [view setAlpha:0.];
        }];
    }
}

- (void)showOrHideVolumePricing {
    if (!_isPricingOpen) {
        [UIView animateWithDuration:defaultAnimationDuration
                         animations:^{
                             [[self.priceMatrix subviews] bk_each:^(UIView *view) {
                                 [view setAlpha:1.];
                                 [view cas_addStyleClass:@"expanded"];
                             }];
                             [self.priceMatrix cas_addStyleClass:@"expandedPriceMatrix"];
                             
                             [self.volumePricesPanel cas_removeStyleClass:@"collapsed"];
                             [self.volumePricesPanel cas_addStyleClass:@"expanded"];
                             
                             [self.volumePricingButton cas_addStyleClass:@"expanded"];
                             [self.productPriceLabel cas_addStyleClass:@"expanded"];
                             [self.productPriceLabelSeparator cas_addStyleClass:@"expanded"];
                             
                             [self cas_updateStyling];
                         }];
        self.volumePricesPanel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_VOLUME_PRICING_EXPANDED";
        _isPricingOpen = YES;
    } else {
        [UIView animateWithDuration:defaultAnimationDuration
                         animations:^{
                             [[self.priceMatrix subviews] bk_each:^(UIView *view) {
                                 [view setAlpha:0.];
                                 [view cas_removeStyleClass:@"expanded"];
                             }];
                             [self.priceMatrix cas_removeStyleClass:@"expandedPriceMatrix"];
                             
                             [self.volumePricesPanel cas_addStyleClass:@"collapsed"];
                             [self.volumePricesPanel cas_removeStyleClass:@"expanded"];
                             
                             [self.volumePricingButton cas_removeStyleClass:@"expanded"];
                             [self.productPriceLabel cas_removeStyleClass:@"expanded"];
                             [self.productPriceLabelSeparator cas_removeStyleClass:@"expanded"];
                             
                             [self cas_updateStyling];
                         }];
        self.volumePricesPanel.accessibilityIdentifier = @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_VOLUME_PRICING_CLOSED";
        _isPricingOpen = NO;
    }
}

- (void)calculateTotalPrice {
    NSNumber *result = [self currentQuantity];
    if (result) {
        CGFloat totalPrice = [[_product price] floatValue] * result.intValue;
        self.totalItemPrice.text = [[NSString alloc] initWithFormat:@"%.02f %@", totalPrice, _product.currencyIso];
    }
}

- (NSNumber *)currentQuantity {
    return [[[NSNumberFormatter alloc] init] numberFromString:self.quantityInputField.text];
}

//recursively browse products variants, looking for matching product code

-(void)recursivePreselectionVariants {
    [self isChildOfVariant:self.product.variants depth:0];
}

-(void)isChildOfVariant:(NSArray*)variants depth:(int)depth {
    
    NSString *lookupCode = self.product.code;
    
    int idx = 0;
    
    for (HYBProductVariantOption* childVariant in variants) {
        if([childVariant.code isEqualToString:lookupCode]) {
            depth++;
            [self isChildOfVariant:childVariant.variants depth:depth];
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:selectedVariantsDict];
            [tempDict setValue:[NSNumber numberWithInt:idx] forKey:[NSString stringWithFormat:@"%d",depth-1]];
            [self setSelectedVariantsDict:[NSDictionary dictionaryWithDictionary:tempDict]];
            
            break;
        }
        idx++;
    }
    
}

#pragma mark - Variants Methods (Picker View for Variants)

- (void)buildUpVariants {
    //find the currently selected item based on product code and prefill the values
    [self recursivePreselectionVariants];
    
    //get current variant
    _currentVariantsMatrix = [self variantsAsMatrix];
    
    if ([_currentVariantsMatrix hyb_isNotBlank]) {
        self.variantSelectionButtons = [NSMutableArray array];
        
        [self.variantButtonsPanel removeAllSubViews];
        
        for (int j = 0; j < _currentVariantsMatrix.count; j++) {
            
            
            NSString *buttonTitle = nil;
            
            NSString *key = [NSString stringWithFormat:@"%d",j];
            NSNumber *selectedRow = self.selectedVariantsDict[key];
            
            if(selectedRow) {
                buttonTitle = [[[_currentVariantsMatrix objectAtIndex:j] objectAtIndex:[selectedRow intValue]] categoryValue];
            } else {
                buttonTitle = [[[_currentVariantsMatrix objectAtIndex:j] firstObject] categoryName];
            }
            
            UIButton *variantButton = [[UIButton alloc] initWithStyleClassId:@"dropdownButton" title:buttonTitle];
            [variantButton layoutAsDropdownButton];
            
            NSString *buttonAccessId = [NSString stringWithFormat:@"%@_%d", @"ACCESS_CONTENT_PRODUCTDETAILS_PRODUCT_VARIANTS_BUTTON", j];
            variantButton.accessibilityIdentifier = buttonAccessId;
            
            [self.variantButtonsPanel addSubview:variantButton];
            [self.variantSelectionButtons addObject:variantButton];
            
            [variantButton addTarget:self action:@selector(showVariantPicker) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)hideVariantPicker {
    [UIView animateWithDuration:defaultAnimationDuration
                     animations:^{
                         _variantValuePickerPanel.frame = CGRectMake(0, CGRectGetMaxY(self.bounds), [self totalWidth], [self totalHeight] * 1 / 3);
                         _maskView.alpha = 0.f;
                     }
                     completion:^(BOOL finished) {
                         [_variantValuePickerPanel removeFromSuperview];
                         [_maskView removeFromSuperview];
                         [self buildUpVariants];
                     }
     ];
}


- (void)showVariantPicker {
    float pickerHeight = 216.0;
    
    _maskView = [[UIView alloc] initWithFrame:self.frame];
    _maskView.backgroundColor = [UIColor whiteColor];
    _maskView.alpha = 0.f;
    
    [self addSubview:_maskView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideVariantPicker)];
    tapRecognizer.numberOfTapsRequired = 1;
    
    [_maskView addGestureRecognizer:tapRecognizer];
    
    CGFloat pickerPanelHeight = [self totalHeight] * 1 / 3;
    _variantValuePickerPanel = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds), [self totalWidth], pickerPanelHeight)];
    _variantValuePickerPanel.alpha = 0.f;
    _variantValuePickerPanel.backgroundColor = [[UIColor alloc] initWithString:@"#EEEEEE"];
    [self addSubview:_variantValuePickerPanel];
    
    CGRect pickerFrame = CGRectMake(defaultIndentation, defaultIndentation, [self totalWidth] - 2 * defaultIndentation, pickerHeight);
    _variantValuePicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    [_variantValuePicker setDataSource:self];
    [_variantValuePicker setDelegate:self];
    
    
    if([[selectedVariantsDict allKeys] count] > 0) {
        //preload previous selection
        
        int nbOfComp = (int)[self numberOfComponentsInPickerView:_variantValuePicker];
        
        for (int i = 0; i < nbOfComp; i++) {
            int preselectedRow = [[selectedVariantsDict valueForKey:[NSString stringWithFormat:@"%d",i]] intValue];
            [_variantValuePicker selectRow:preselectedRow inComponent:i animated:NO];
        }
    }
    
    //
    
    CGPoint position = CGPointMake(defaultIndentation, CGRectGetMaxY(_variantValuePickerPanel.bounds)
                                   - HYBButton.primaryButtonHeight - defaultIndentation);
    
    
    CGFloat buttonWitdh =  _variantValuePickerPanel.bounds.size.width/2 - position.x * 1.5;
    
    //cancel picker btn
    _variantSelectionCancelButton.frame = CGRectMake(position.x, position.y, buttonWitdh, primButtonHeight);
    [_variantSelectionCancelButton setTitle:NSLocalizedString(@"product_details_buttons_cancel_variant", nil) forState:UIControlStateNormal];
    
    [_variantValuePickerPanel addSubview:_variantSelectionCancelButton];
    
    _variantSelectionCancelButton.accessibilityIdentifier = @"ACCESS_VARIANT_PICKER_CANCEL";
    
    // apply picker btn
    _variantSelectionDoneButton.frame = CGRectMake(position.x*2+buttonWitdh, position.y,buttonWitdh, primButtonHeight);
    [_variantSelectionDoneButton setTitle:NSLocalizedString(@"product_details_buttons_select_variant", nil) forState:UIControlStateNormal];
    
    _variantSelectionDoneButton.accessibilityIdentifier = @"ACCESS_VARIANT_PICKER_APPLY";
    
    [_variantValuePickerPanel addSubview:_variantSelectionDoneButton];
    [_variantValuePickerPanel addSubview:_variantValuePicker];
    
    [UIView animateWithDuration:defaultAnimationDuration
                     animations:^{
                         
                         _variantValuePickerPanel.frame = CGRectMake(0, self.bounds.size.height * 1 / 3, [self totalWidth], pickerPanelHeight);
                         
                         _maskView.alpha = .8;
                         _variantValuePickerPanel.alpha = 1.f;
                     }];
}

- (NSArray *)variantsAsMatrix {
    NSMutableArray *result = [NSMutableArray array];
    
    if ([[self.product variants] hyb_isNotBlank]) {
        
        id parent = [self product];
        
        for (int currentDimension = 0; currentDimension < [self.product variantDimensionsNumber]; currentDimension++) {
            NSString *key = [NSString stringWithFormat:@"%d",currentDimension];
            int index = [self.selectedVariantsDict[key] intValue];
            
            NSArray *siblingVariants = [parent variants];
            [result addObject:siblingVariants];            
            parent = [siblingVariants objectAtIndex:index];
        }
    }
    
    return result;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [_currentVariantsMatrix count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[_currentVariantsMatrix objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[_currentVariantsMatrix objectAtIndex:component] objectAtIndex:row] categoryValue];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [self selectPathWithComponent:component andRow:row];
    
    if (component < self.product.variantDimensionsNumber - 1) {
        
        //not leaf selected, refresh needed for all previous components
        for (int subComponentIndex = (int)component + 1; subComponentIndex < self.product.variantDimensionsNumber; ++subComponentIndex) {
            [pickerView selectRow:0 inComponent:subComponentIndex animated:YES];
            [pickerView reloadComponent:subComponentIndex];
        }
    }
    
    NSString *key = [NSString stringWithFormat:@"%d",self.product.variantDimensionsNumber - 1];
    int lastDimensionRow = [self.selectedVariantsDict[key] intValue];
    
    HYBProductVariantOption *variantOption = [[_currentVariantsMatrix objectAtIndex:self.product.variantDimensionsNumber - 1] objectAtIndex:lastDimensionRow];
    
    self.selectedVariantCode = variantOption.code;
    
    // set the selected value on the button
    NSString *value = [self pickerView:pickerView titleForRow:row forComponent:component];
    [[self.variantSelectionButtons objectAtIndex:component] setTitle:value forState:UIControlStateNormal];
    
}

- (void)selectPathWithComponent:(NSInteger)component andRow:(NSInteger)row {
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:self.selectedVariantsDict];
    
    [tmpDict setObject:[NSNumber numberWithInteger:row] forKey:[NSString stringWithFormat:@"%d",(int)component]];
    
    if (component < [[tmpDict allKeys] count] - 1) {
        // set all the following component indexes to 0, since parent has changed
        for (int subComponent = (int)component + 1; subComponent < _product.variantDimensionsNumber; ++subComponent) {
            [tmpDict setObject:@0 forKey:[NSString stringWithFormat:@"%d",(int)subComponent]];
        }
    }
    
    self.selectedVariantsDict = [NSDictionary dictionaryWithDictionary:tmpDict];
    
    //reload variants
    _currentVariantsMatrix = [self variantsAsMatrix];
}

#pragma mark - Bottom Tabs Methods

- (void)buildTabsTable {
    DDLogDebug(@"buildTabsTable");
    
    self.tabsTable.delegate = self;
    self.tabsTable.dataSource = self;
    
    self.tabsTable.scrollEnabled = NO;
    
    self.tabsTable.contentInset = UIEdgeInsetsZero;
    self.tabsTable.separatorInset = UIEdgeInsetsZero;
    
    self.tabsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self updateVisibleTableContent];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
        [cell cas_addStyleClass:@"tabsTableCell"];
    }
    
    [cell.contentView removeAllSubViews];
    
    NSDictionary *dict = self.visibleTableContent[indexPath.row];
    
    NSString *status = dict[@"status"];
    
    BOOL isOpen = NO;
    
    if([status isEqualToString:@"title"]) {
        if (indexPath.row < [self.visibleTableContent count]-1) {
            NSDictionary *contentDict = self.visibleTableContent[indexPath.row+1];
            NSString *contentStatus = contentDict[@"status"];
            if([contentStatus isEqualToString:@"open"]) {
                isOpen = YES;
            }
        }
        
        UILabel *label = [UILabel new];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        
        NSString *accessTag = nil;
        
        if (isOpen) {
            label.text = @"-";
            accessTag = [NSString stringWithFormat:@"ACCESS_PRODUCTDETAIL_TABS_CLOSE_CELL_%ld",(long)indexPath.row];
        } else {
            label.text = @"+";
            accessTag = [NSString stringWithFormat:@"ACCESS_PRODUCTDETAIL_TABS_OPEN_CELL_%ld",(long)indexPath.row];
        }
        
        [label sizeToFit];
        
        cell.accessoryView.accessibilityIdentifier = accessTag;
        cell.accessoryView = label;
    } else {
        cell.accessoryView = nil;
    }
    
    NSString *cacheKey =  dict[@"accessId"];
    
    
    UIView *view = _tableCellsCacheDict[cacheKey];
    
    if(!view) {
        view = [self viewForContentDict:dict];
        [_tableCellsCacheDict setObject:view forKey:cacheKey];
    }
    
    [cell.contentView addSubview:view];
    
    cell.accessibilityIdentifier = dict[@"accessId"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *currentCellDict = self.visibleTableContent[indexPath.row];
    int currentTag = [currentCellDict[@"tag"] intValue];
    
    for (NSDictionary *dict in self.tableContent) {
        if([dict[@"tag"] intValue] == currentTag) {
            
            //tap on the title
            if([dict[@"status"] isEqualToString:@"title"]) {
                int titleIndex = (int)[self.tableContent indexOfObject:dict];
                [self toggleCellForTitleIndex:titleIndex];
            }
            
            //tap on the content
            else if([dict[@"status"] isEqualToString:@"open"]) {
                int titleIndex = (int)[self.tableContent indexOfObject:dict];
                [self toggleCellForTitleIndex:titleIndex-1];
            }
            
            break;
        }
    }
    
    [self updateVisibleTableContent];
}

- (void)toggleCellForTitleIndex:(int)titleIndex {
    
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.tableContent];
    
    int contentIndex = titleIndex+1;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.tableContent objectAtIndex:contentIndex]];
    
    if([dict[@"status"] isEqualToString:@"closed"]) {
        [dict setObject:@"open" forKey:@"status"];
    } else {
        [dict setObject:@"closed" forKey:@"status"];
    }
    
    [tmpArray replaceObjectAtIndex:contentIndex withObject:[NSDictionary dictionaryWithDictionary:dict]];
    
    self.tableContent = [NSArray arrayWithArray:tmpArray];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = self.visibleTableContent[indexPath.row];
    
    UIView *view = [self viewForContentDict:dict];
    
    CGFloat h = view.frame.size.height;
    
    if (h < 24) h = 24;
    
    return h + 30;
}

- (UIView*)viewForContentDict:(NSDictionary*)dict {
    
    UIView *container = [UIView new];
    
    NSString *content = dict[@"content"];
    NSString *status  = dict[@"status"];
    
    //setup styling size
    
    NSString *fontName = @"HelveticaNeue";
    NSString *fontSize = @"17";
    
    if([status isEqualToString:@"title"]) {
        fontName = @"HelveticaNeue-Medium";
        fontSize = @"19";
    }
    
    NSString *styledContent = [NSString stringWithFormat:@"<div style=\"font-family:'%@';font-size:%@px;\">%@</div>", fontName,fontSize, content];
    
    //render string
    NSAttributedString *attributedContent = [[NSAttributedString alloc] initWithData:[styledContent dataUsingEncoding:NSUnicodeStringEncoding]
                                                                             options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                  documentAttributes:nil
                                                                               error:nil];
    
    //sizing
    CGFloat padding = 10.f;
    CGFloat maxWidth = 700-padding*3;
    CGSize constraint = CGSizeMake(maxWidth,NSUIntegerMax);
    
    
    CGRect rect = [attributedContent boundingRectWithSize:constraint
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  context:nil];
    
    // Construct label
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, maxWidth, rect.size.height+padding)];
    
    label.attributedText = attributedContent;
    label.textAlignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    [container setFrame:label.frame];
    [container addSubview:label];
    
    return container;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.visibleTableContent count];
}

- (BOOL)isAlreadyUp {
    return self.isUp;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.masterScrollView setContentOffset:CGPointMake(0, 120) animated:YES];
    return YES;
}

#pragma mark - Utils

- (CGFloat)totalWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)totalHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGFloat)width:(UIView *)view {
    return view.frame.size.width;
}

- (void)setQTY:(NSString *)quantity {
    [self.quantityInputField setText:quantity];
    [self calculateTotalPrice];
}
@end