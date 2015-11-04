//
// HYBProductDetailsController.h
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

#import <UIKit/UIKit.h>
#import "HYBViewController.h"
#import "HYBProduct.h"

@protocol HYBBackEndFacade;
@class HYBButton;

@interface HYBProductDetailsController : HYBViewController <UIScrollViewDelegate>

@property(strong, nonatomic, readonly) NSString   *code;
@property(strong, nonatomic, readonly) HYBProduct *product;

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService productId:(NSString *)selectedProductId ;
@end
