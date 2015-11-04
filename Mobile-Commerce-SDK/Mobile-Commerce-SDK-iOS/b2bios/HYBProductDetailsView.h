//
// HYBProductDetailsView.h
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

#import <Foundation/Foundation.h>
#import <ClassyLiveLayout/SHPAbstractView.h>

@class HYBProduct;
@class HYBButton;

@interface HYBProductDetailsView : SHPAbstractView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic)  UIView         *maskView;;
@property(nonatomic)  UIScrollView   *masterScrollView;
@property(nonatomic)  NSDictionary   *selectedVariantsDict;
@property(nonatomic)  UIPageControl  *imagesScrollControl;
@property(nonatomic)  UIScrollView   *imagesScrollView;
@property(nonatomic)  UITextField    *quantityInputField;
@property(nonatomic)  UILabel        *availabilityLabel;
@property(nonatomic)  UILabel        *quantityLabel;
@property(nonatomic)  UILabel        *productPriceLabelSeparator;
@property(nonatomic)  UIButton       *volumePricingButton;
@property(nonatomic)  UIButton       *addToCartButton;
@property(nonatomic)  UIView         *titlePanel;
@property(nonatomic)  UIView         *titleDetailsPanel;
@property(nonatomic)  UIImageView    *closeIcon;
@property(nonatomic)  UILabel        *totalItemPrice;
@property(nonatomic)  NSString       *selectedVariantCode;
@property(nonatomic)  UIView         *quantityInputPanel;

@property(nonatomic, readonly) HYBButton *variantSelectionDoneButton;
@property(nonatomic, readonly) HYBButton *variantSelectionCancelButton;

- (void)loadImagesInView:(NSArray *)productImages;

- (void)loadProductDetails:(HYBProduct *)product;

- (void)showOrHideVolumePricing;

- (void)calculateTotalPrice;

- (NSNumber *)currentQuantity;

- (void)hideVariantPicker;

- (void)setQTY:(NSString *)quantity;
@end