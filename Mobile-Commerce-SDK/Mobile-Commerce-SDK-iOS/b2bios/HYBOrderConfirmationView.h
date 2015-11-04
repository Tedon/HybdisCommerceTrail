//
// HYBOrderConfirmationView.h
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
#import "HYBOrderSummaryView.h"

@class HYBCustButton;
@class HYBButton;

@interface HYBOrderConfirmationView : SHPAbstractView

@property(nonatomic, strong) HYBButton *continueShoppingButton;
@property(nonatomic, strong) UILabel *thanksLabel;
@property(nonatomic, strong) UIView *orderNumberPanel;
@property(nonatomic, strong) UILabel *orderNumberIntroLabel;
@property(nonatomic, strong) UILabel *orderNumberLinkLabel;
@property(nonatomic, strong) UILabel *emailDetailsLabel;
@property(nonatomic, strong) UITableView *itemsTable;

@property(nonatomic, strong) UIView *deliveryMainPanel;
@property(nonatomic, strong) UIView *deliveryAddressPanel;
@property(nonatomic, strong) UILabel *deliveryAddressTitle;
@property(nonatomic, strong) UILabel *deliveryAddressValue;
@property(nonatomic, strong) UIView *deliveryMethodPanel;
@property(nonatomic, strong) UILabel *deliveryMethodTitle;
@property(nonatomic, strong) UILabel *deliveryMethodValue;

@property(nonatomic, strong) HYBOrderSummaryView *orderSummaryView;

@end
