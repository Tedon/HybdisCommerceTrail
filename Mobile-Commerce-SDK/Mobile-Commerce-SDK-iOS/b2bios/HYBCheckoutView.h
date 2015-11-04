//
// HYBCheckoutView.h
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
#import "UIButton+HYBButton.h"
#import "HYBOrderSummaryView.h"

@class HYBCustButton;
@class HYBButton;


@interface HYBCheckoutView : SHPAbstractView 

@property(nonatomic,  strong)  UILabel        *checkoutTitle;

@property(nonatomic,  strong)  UIView         *paymentPanel;
@property(nonatomic,  strong)  UILabel        *paymentTitle;
@property(nonatomic,  strong)  UIView         *paymentAccountPanel;
@property(nonatomic,  strong)  HYBCustButton  *paymentAccount;
@property(nonatomic,  strong)  UIButton       *paymentQuestionMarkButton;
@property(nonatomic,  strong)  UIView         *paymentPONumberPanel;
@property(nonatomic,  strong)  UITextField    *paymentPONumberField;

@property(nonatomic,  strong)  UIView         *costCenterPanel;
@property(nonatomic,  strong)  UILabel        *costCenterTitle;
@property(nonatomic,  strong)  HYBCustButton  *costCenterButton;

@property(nonatomic,  strong)  UIView         *deliveryPanel;
@property(nonatomic,  strong)  UILabel        *deliveryDetailsTitle;
@property(nonatomic,  strong)  UILabel        *deliveryAddressTitle;
@property(nonatomic,  strong)  HYBCustButton  *deliveryAddressButton;
@property(nonatomic,  strong)  UILabel        *deliveryMethodTitle;
@property(nonatomic,  strong)  HYBCustButton  *deliveryMethodButton;

@property(nonatomic,  strong)  UIView          *agreementPanel;
@property(nonatomic,  strong)  HYBButton      *agreementButton;
@property(nonatomic,  strong)  UILabel        *agreementIntroLabel;
@property(nonatomic,  strong)  UILabel        *agreementLinkLabel;

@property(nonatomic,  strong)  UILabel        *agreementConfirmationLabel;

@property(nonatomic,  strong)  HYBButton      *orderButton;

@property(nonatomic,  strong)  UIView         *maskView;

@property(nonatomic, strong) HYBOrderSummaryView *orderSummaryView;

@end