//
// HYBOrderConfirmationView.m
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

#import "HYBOrderConfirmationView.h"
#import "UIView+HYBBase.h"
#import "UILabel+HYBLabel.h"
#import "HYBButton.h"

@implementation HYBOrderConfirmationView

/**
 *  generate view layout
 */
- (void)addSubviews {

    self.continueShoppingButton = [[HYBButton alloc] initWithStyleClassId:@"continueShoppingButton alignCenter"
                                                                    title:NSLocalizedString(@"postcheckout_continue_shopping", nil)];

    [self addSubview:self.continueShoppingButton];


    self.thanksLabel = [[UILabel alloc] initWithStyleClassId:@"thanksLabel"
                                                        text:NSLocalizedString(@"postcheckout_thansk_label", nil)];
    self.thanksLabel.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_THANK_YOU";
    
    [self addSubview:self.thanksLabel];

    self.orderNumberPanel = [[UIView alloc] initWithStyleClassId:@"orderNumberPanel"];
    [self addSubview:self.orderNumberPanel];

    self.orderNumberIntroLabel = [[UILabel alloc] initWithStyleClassId:@"orderNumberIntroLabel"
                                                                  text:NSLocalizedString(@"postcheckout_order_number_intro", nil)];
    [self.orderNumberPanel addSubview:self.orderNumberIntroLabel];

    self.orderNumberLinkLabel = [[UILabel alloc] initWithStyleClassId:@"orderNumberLinkLabel"
                                                                 text:NSLocalizedString(@"postcheckout_order_number_link", nil)];
    [self.orderNumberPanel addSubview:self.orderNumberLinkLabel];

    self.emailDetailsLabel = [[UILabel alloc] initWithStyleClassId:@"emailDetailsLabel"
                                                              text:@""];
    [self addSubview:self.emailDetailsLabel];


    self.deliveryMainPanel = [[UIView alloc] initWithStyleClassId:@"deliveryMainPanel"];
    [self addSubview:self.deliveryMainPanel];

    self.deliveryAddressPanel = [[UIView alloc] initWithStyleClassId:@"deliveryAddressPanel"];
    [self.deliveryMainPanel addSubview:self.deliveryAddressPanel];

    self.deliveryAddressTitle = [[UILabel alloc] initWithStyleClassId:@"deliveryAddressTitle"
                                                                 text:NSLocalizedString(@"deliveryAddress_label_title", nil)];
    self.deliveryAddressTitle.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_DELIVERY_ADDRESS_TITLE";
    
    [self.deliveryAddressPanel addSubview:self.deliveryAddressTitle];

    self.deliveryAddressValue = [[UILabel alloc] initWithStyleClassId:@"deliveryAddressValue"
                                                                 text:@""];
    self.deliveryAddressValue.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_DELIVERY_ADDRESS";
    
    [self.deliveryAddressValue setNumberOfLines:0];

    [self.deliveryAddressPanel addSubview:self.deliveryAddressValue];


    self.deliveryMethodPanel = [[UIView alloc] initWithStyleClassId:@"deliveryMethodPanel"];
    [self.deliveryMainPanel addSubview:self.deliveryMethodPanel];

    self.deliveryMethodTitle = [[UILabel alloc] initWithStyleClassId:@"deliveryMethodTitle"
                                                                text:NSLocalizedString(@"deliveryMethod_label_title", nil)];
    
    self.deliveryMethodTitle.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_DELIVERY_METHOD_TITLE";
    
    [self.deliveryMethodPanel addSubview:self.deliveryMethodTitle];

    self.deliveryMethodValue = [[UILabel alloc] initWithStyleClassId:@"deliveryMethodValue"
                                                                text:@""];
    self.deliveryMethodValue.accessibilityIdentifier = @"ACCESS_ORDER_CONFIRMATION_DELIVERY_METHOD";

    [self.deliveryMethodValue setNumberOfLines:0];

    [self.deliveryMethodPanel addSubview:self.deliveryMethodValue];

    self.orderSummaryView = [[HYBOrderSummaryView alloc] init];

    [self addSubview:self.orderSummaryView];

    self.itemsTable = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.itemsTable.cas_styleClass = @"itemsTable";
    
    [self addSubview:self.itemsTable];
}

- (void)updateConstraints {
    [super updateConstraints];

    [self.orderNumberPanel layoutSubviewsHorizontally];
    [self.deliveryMainPanel layoutSubviewsHorizontally];
    [self.deliveryAddressPanel layoutSubviewsVertically];
    [self.deliveryMethodPanel layoutSubviewsVertically];

    [self layoutSubviewsVertically];
}

- (void)defineLayout {

}

@end
