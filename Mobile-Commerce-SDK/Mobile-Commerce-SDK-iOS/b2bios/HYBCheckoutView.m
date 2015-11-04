//
// HYBCheckoutView.m
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
#import "HYBCheckoutView.h"
#import "UIView+HYBBase.h"
#import "UILabel+HYBLabel.h"
#import <ColorUtils/ColorUtils.h>
#import "UIView+CASAdditions.h"
#import "HYBCustButton.h"
#import "HYBButton.h"


@implementation HYBCheckoutView

@synthesize maskView;

/**
 *  generate view layout
 */
- (void)addSubviews {

    //checkout title
    self.checkoutTitle = [[UILabel alloc] initWithStyleClassId:@"titleLabel"
                                                          text:NSLocalizedString(@"checkout_label_title", nil)];
    [self addSubview:self.checkoutTitle];
    
    //payment panel
    self.paymentPanel = [[UIView alloc] initWithStyleClassId:@"paymentPanel"];
    [self addSubview:self.paymentPanel];
    
    self.paymentTitle = [[UILabel alloc] initWithStyleClassId:@"subTitleLabel"
                                                         text:NSLocalizedString(@"payment_label_title", nil)];
    [self.paymentPanel addSubview:self.paymentTitle];
    
    self.paymentAccountPanel = [[UIView alloc] initWithStyleClassId:@"paymentAccountPanel"];
    [self.paymentPanel addSubview:self.paymentAccountPanel];
    
    self.paymentAccount = [[HYBCustButton alloc] initWithStyleClassId:@"dropdownButton paymentAccountButton" text:@""];
    self.paymentAccount.label.cas_styleClass = @"subTitleLabel";


    [self.paymentAccountPanel addSubview:self.paymentAccount];

    self.paymentQuestionMarkButton = [[UIButton alloc] initWithStyleClassId:@"paymentQuestionMarkButton"
                                                                         title:NSLocalizedString(@"?", nil)];
    [[self.paymentQuestionMarkButton layer] setCornerRadius:15];
    [[self.paymentQuestionMarkButton layer] setMasksToBounds:YES];
    
    [self.paymentAccountPanel addSubview:self.paymentQuestionMarkButton];
    
    self.paymentPONumberPanel = [[UIView alloc] initWithStyleClassId:@"paymentPONumberPanel"];
    [self.paymentPanel addSubview:self.paymentPONumberPanel];

    [[self.paymentPONumberPanel layer] setBorderWidth:1.0f];
    [[self.paymentPONumberPanel layer] setBorderColor:[[UIColor alloc] initWithString:@"#b8bec8"].CGColor];
    
    self.paymentPONumberField = [[UITextField alloc] initWithFrame:CGRectInset(self.paymentPONumberPanel.bounds, 10, 10)];
    self.paymentPONumberField.cas_styleClass = @"paymentPONumberField";
    self.paymentPONumberField.placeholder = NSLocalizedString(@"payment_po_number_optional", nil);
    self.paymentPONumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.paymentPONumberField.clearsOnBeginEditing = NO;
           
    [self.paymentPONumberPanel addSubview:self.paymentPONumberField];
    
    //cost center panel
    self.costCenterPanel = [[UIView alloc] initWithStyleClassId:@"costCenterPanel"];
    [self addSubview:self.costCenterPanel];
    
    self.costCenterTitle = [[UILabel alloc] initWithStyleClassId:@"subTitleLabel"
                                                            text:NSLocalizedString(@"costCenter_label_title", nil)];
    [self.costCenterPanel addSubview:self.costCenterTitle];
    
    self.costCenterButton = [[HYBCustButton alloc] initWithStyleClassId:@"dropdownButton costCenterButton" text:@""];
    self.costCenterButton.label.cas_styleClass = @"subTitleLabel";
    
    [self.costCenterPanel addSubview:self.costCenterButton];
    
    //delivery details panel
    self.deliveryPanel = [[UIView alloc] initWithStyleClassId:@"deliveryPanel"];
    [self addSubview:self.deliveryPanel];
    
    self.deliveryDetailsTitle = [[UILabel alloc] initWithStyleClassId:@"subTitleLabel"
                                                                 text:NSLocalizedString(@"deliveryDetails_label_title", nil)];
    [self.deliveryPanel addSubview:self.deliveryDetailsTitle];
    
    self.deliveryAddressTitle = [[UILabel alloc] initWithStyleClassId:@"subSubTitleLabel"
                                                                 text:NSLocalizedString(@"deliveryAddress_label_title", nil)];
   [self.deliveryPanel addSubview:self.deliveryAddressTitle];

    self.deliveryAddressButton = [[HYBCustButton alloc] initWithStyleClassId:@"dropdownButton deliveryAddressButton" text:NSLocalizedString(@"delivery_address_selection", nil)];
    self.deliveryAddressButton.label.cas_styleClass = @"subTitleLabel";

    [self.deliveryPanel addSubview:self.deliveryAddressButton];
    
    self.deliveryMethodTitle = [[UILabel alloc] initWithStyleClassId:@"subSubTitleLabel"
                                                                text:NSLocalizedString(@"deliveryMethod_label_title", nil)];
    [self.deliveryPanel addSubview:self.deliveryMethodTitle];


    self.deliveryMethodButton = [[HYBCustButton alloc] initWithStyleClassId:@"dropdownButton deliveryMethodButton" text:NSLocalizedString(@"deliveryMethod_label_title", nil)];
    self.deliveryMethodButton.label.cas_styleClass = @"subTitleLabel";

    [self.deliveryPanel addSubview:self.deliveryMethodButton];
    
    //agreement panel
    self.agreementPanel = [[UIView alloc] initWithStyleClassId:@"agreementPanel"];
    [self addSubview:self.agreementPanel];
    
    self.agreementButton = [[HYBButton alloc] initWithStyleClassId:@"agreementButton" title:@" "];
    [[self.agreementButton layer] setCornerRadius:4];
    [[self.agreementButton layer] setMasksToBounds:YES];
    
    [self.agreementPanel addSubview:self.agreementButton];
    
    self.agreementIntroLabel = [[UILabel alloc] initWithStyleClassId:@"agreementLabel"
                                                                 text:NSLocalizedString(@"agreement_label_intro", nil)];
    [self.agreementPanel addSubview:self.agreementIntroLabel];
    
    self.agreementLinkLabel = [[UILabel alloc] initWithStyleClassId:@"agreementLink"
                                                                text:NSLocalizedString(@"agreement_label_link", nil)];
    [self.agreementPanel addSubview:self.agreementLinkLabel];
    
    self.agreementConfirmationLabel  = [[UILabel alloc] initWithStyleClassId:@"agreementConfirmation"
                                                                        text:NSLocalizedString(@"agreement_label_confirmation", nil)];
    
    self.agreementConfirmationLabel.accessibilityIdentifier = @"ACCESS_CHECKOUT_AGREEMENT_ERROR";
    
    [self addSubview:self.agreementConfirmationLabel];
    self.agreementConfirmationLabel.hidden = YES;
    
    //order button
    self.orderButton = [[HYBButton alloc] initWithStyleClassId:@"orderButton alignCenter"
                                                         title:NSLocalizedString(@"order_button_checkout", nil)];
    [self.orderButton setEnabled:NO];

    [self addSubview:self.orderButton];
    
    //order summary panel
    self.orderSummaryView = [[HYBOrderSummaryView alloc] init];
    
    [self addSubview:self.orderSummaryView];
    
    self.maskView = [[UIView alloc] init];
    self.maskView.backgroundColor = [UIColor whiteColor];
    self.maskView.alpha = 0;
    self.maskView.hidden = YES;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    self.maskView.frame = self.frame;
    
    [self.checkoutTitle         layoutSubviewsVertically];
    [self.paymentPanel          layoutSubviewsVertically];
    [self.paymentPONumberPanel  layoutSubviewsHorizontally];
    [self.paymentAccountPanel   layoutSubviewsHorizontally];
    [self.costCenterPanel       layoutSubviewsVertically];
    [self.costCenterButton      layoutSubviewsHorizontally];
    [self.deliveryPanel         layoutSubviewsVertically];
    [self.agreementPanel        layoutSubviewsHorizontally];
    
    [self layoutSubviewsVertically];

}

- (void)defineLayout {
}

@end