//
// HYBOrderSummaryView.h
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

#import <ClassyLiveLayout/SHPAbstractView.h>
#import "UIButton+HYBButton.h"

@class HYBCustButton;

@interface HYBOrderSummaryView : SHPAbstractView

@property(nonatomic, strong) UIView  *panel;
@property(nonatomic, strong) UIView  *upperPanel;
@property(nonatomic, strong) UIView  *totalPanel;
@property(nonatomic, strong) UILabel *title;
@property(nonatomic, strong) UILabel *itemCount;
@property(nonatomic, strong) UIView  *sumPanel;
@property(nonatomic, strong) UIView  *subTotalPanel;
@property(nonatomic, strong) UILabel *subtotalTitle;
@property(nonatomic, strong) UILabel *subtotalValue;
@property(nonatomic, strong) UIView  *savingsPanel;
@property(nonatomic, strong) UILabel *savingsTitle;
@property(nonatomic, strong) UILabel *savingsValue;
@property(nonatomic, strong) UIView  *taxPanel;
@property(nonatomic, strong) UILabel *taxTitle;
@property(nonatomic, strong) UILabel *taxValue;
@property(nonatomic, strong) UIView  *shippingPanel;
@property(nonatomic, strong) UILabel *shippingTitle;
@property(nonatomic, strong) UILabel *shippingValue;
@property(nonatomic, strong) UIView  *orderTotalPanel;
@property(nonatomic, strong) UILabel *orderTotalTitle;
@property(nonatomic, strong) UILabel *orderTotalValue;
@property(nonatomic, strong) UIView  *savingsRecapPanel;
@property(nonatomic, strong) UILabel *savingsRecapTitle;


@end
