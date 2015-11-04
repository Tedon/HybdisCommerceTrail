//
// HYBCartView.h
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
#import "UIView+HYBFindFirstResponder.h"
#import "SHPAbstractView.h"

@class HYBCustButton;
@class HYBButton;

@interface HYBCartView : SHPAbstractView

@property(nonatomic, strong, readonly) HYBCustButton *checkoutButton;
@property(nonatomic, strong, readonly) HYBButton *continueShoppingButton;

@property(nonatomic,  strong)  UILabel        *cartTotalNumber;
@property(nonatomic,  strong)  UILabel        *cartTotalLabel;
@property(nonatomic,  strong)  UILabel        *taxTitleLabel;
@property(nonatomic,  strong)  UILabel        *taxNumber;
@property(nonatomic,  strong)  UILabel        *subtotalTitleLabel;
@property(nonatomic,  strong)  UILabel        *subTotalNumber;
@property(nonatomic,  strong)  UILabel        *savingsNumber;
@property(nonatomic,  strong)  UILabel        *titleLabel;
@property(nonatomic,  strong)  UITableView    *itemsTable;
@property(nonatomic,  strong)  UIView         *itemsPanelInfoBox;
@property(nonatomic,  strong)  UILabel        *shippingLabel;
@property(nonatomic,  strong)  UILabel        *shippingNumber;
@property(nonatomic,  strong)  UIView         *savingsLabel;
@property(nonatomic,  strong)  UILabel        *discountsMessage;
@property(nonatomic,  strong)  UILabel        *cartTotalTitleLabel;
@property(nonatomic,  strong)  HYBCustButton  *batchToggleButton;
@property(nonatomic,  strong)  UIView         *batchDeletePanel;
@property(nonatomic,  strong)  HYBCustButton  *batchSelectButton;
@property(nonatomic,  strong)  HYBCustButton  *batchDeleteButton;

- (void)setCartToEmpty;

- (void)setCartToNotEmpty;

- (void)hideCart:(BOOL)hide;
@end