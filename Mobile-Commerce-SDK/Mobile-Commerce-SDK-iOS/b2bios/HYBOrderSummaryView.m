//
// HYBOrderSummaryView.m
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

#import "HYBOrderSummaryView.h"
#import "UIView+HYBBase.h"
#import "UILabel+HYBLabel.h"
#import <ColorUtils/ColorUtils.h>
#import "UIView+CASAdditions.h"
#import "HYBCustButton.h"

@implementation HYBOrderSummaryView

/**
 *  generate view layout
 */
- (void)addSubviews {
    self.panel = [[UIView alloc] initWithStyleClassId:@"orderSummaryPanel"];
    [self addSubview:self.panel];

    self.upperPanel = [[UIView alloc] initWithStyleClassId:@"orderSummaryUpperPanel"];
    [self.panel addSubview:self.upperPanel];

    self.totalPanel = [[UIView alloc] initWithStyleClassId:@"orderSummaryTotalPanel"];
    [self.upperPanel addSubview:self.totalPanel];

    self.title = [[UILabel alloc] initWithStyleClassId:@"orderSummaryTitle"
                                                  text:NSLocalizedString(@"order_summary", nil)];
    [self.totalPanel addSubview:self.title];

    self.itemCount = [[UILabel alloc] initWithStyleClassId:@"orderSummaryItemCount"
                                                      text:@"xx"];

    self.itemCount.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_SUMMARY_ITEM_COUNT";

    [self.totalPanel addSubview:self.itemCount];


    self.sumPanel = [[UIView alloc] initWithStyleClassId:@"orderSummarySumPanel"];
    [self.upperPanel addSubview:self.sumPanel];

    self.subTotalPanel = [[UIView alloc] initWithStyleClassId:@"orderSummaryBaseLinePanel"];
    [self.sumPanel addSubview:self.subTotalPanel];

    self.subtotalTitle = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineTitle"
                                                          text:NSLocalizedString(@"order_summary_subtotal", nil)];
    [self.subTotalPanel addSubview:self.subtotalTitle];

    self.subtotalValue = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineValue"
                                                          text:@"$00.00"];

    self.subtotalValue.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_SUMMARY_SUBTOTAL";


    [self.subTotalPanel addSubview:self.subtotalValue];

    self.savingsPanel = [[UIView alloc] initWithStyleClassId:@"orderSummaryBaseLinePanel"];
    [self.sumPanel addSubview:self.savingsPanel];

    self.savingsTitle = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineTitle orderSummarySavings"
                                                         text:NSLocalizedString(@"order_summary_savings", nil)];
    [self.savingsPanel addSubview:self.savingsTitle];

    self.savingsValue = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineValue orderSummarySavings"
                                                         text:@"$00.00"];

    self.savingsValue.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_SUMMARY_SAVINGS";

    [self.savingsPanel addSubview:self.savingsValue];

    self.taxPanel = [[UIView alloc] initWithStyleClassId:@"orderSummaryBaseLinePanel"];
    [self.sumPanel addSubview:self.taxPanel];

    self.taxTitle = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineTitle"
                                                     text:NSLocalizedString(@"order_summary_tax", nil)];
    [self.taxPanel addSubview:self.taxTitle];

    self.taxValue = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineValue"
                                                     text:@"$00.00"];

    self.taxValue.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_SUMMARY_TAX";

    [self.taxPanel addSubview:self.taxValue];


    self.shippingPanel = [[UIView alloc] initWithStyleClassId:@"orderSummaryBaseLinePanel"];
    [self.sumPanel addSubview:self.shippingPanel];

    self.shippingTitle = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineTitle"
                                                          text:NSLocalizedString(@"order_summary_shipping", nil)];
    [self.shippingPanel addSubview:self.shippingTitle];

    self.shippingValue = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineValue"
                                                          text:@"$00.00"];

    self.shippingValue.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_SUMMARY_SHIPPING";

    [self.shippingPanel addSubview:self.shippingValue];


    self.orderTotalPanel = [[UIView alloc] initWithStyleClassId:@"orderSummaryBaseLinePanel"];
    [self.sumPanel addSubview:self.orderTotalPanel];

    self.orderTotalTitle = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineTitle orderSummaryTotal"
                                                            text:NSLocalizedString(@"order_summary_total", nil)];
    [self.orderTotalPanel addSubview:self.orderTotalTitle];

    self.orderTotalValue = [[UILabel alloc] initWithStyleClassId:@"orderSummaryBaseLineValue orderSummaryTotal"
                                                            text:@"$00.00"];

    self.orderTotalValue.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_SUMMARY_TOTAL";

    [self.orderTotalPanel addSubview:self.orderTotalValue];


    self.savingsRecapPanel = [[UIView alloc] initWithStyleClassId:@"orderSummarySavingsRecapPanel"];
    [self.panel addSubview:self.savingsRecapPanel];

    NSString *value1 = @"$45.00";
    NSString *value2 = @"$500.00";
    NSString *ammountRecap = [NSString stringWithFormat:NSLocalizedString(@"you_saved_xx_because", nil), value1, value2];

    self.savingsRecapTitle = [[UILabel alloc] initWithStyleClassId:@"orderSummarySavingsRecapTitle"
                                                              text:ammountRecap];

    self.savingsRecapTitle.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_SUMMARY_SAVINGS_RECAP";

    [self.savingsRecapPanel addSubview:self.savingsRecapTitle];
}

- (void)updateConstraints {
    [super updateConstraints];

    [self.panel layoutSubviewsVertically];
    [self.upperPanel layoutSubviewsHorizontally];
    [self.totalPanel layoutSubviewsVertically];
    [self.sumPanel layoutSubviewsVertically];
    [self.subTotalPanel layoutSubviewsHorizontally];
    [self.savingsPanel layoutSubviewsHorizontally];
    [self.taxPanel layoutSubviewsHorizontally];
    [self.shippingPanel layoutSubviewsHorizontally];
    [self.orderTotalPanel layoutSubviewsHorizontally];
    [self.savingsRecapPanel layoutSubviewsHorizontally];

    [self layoutSubviewsVertically];
}

- (void)defineLayout {

}

@end
