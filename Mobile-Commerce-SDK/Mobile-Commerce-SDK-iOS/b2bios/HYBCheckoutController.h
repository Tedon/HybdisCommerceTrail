//
// HYBCheckoutController.h
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
#import "HYBViewController.h"

#import "HYBCustButton.h"

@protocol HYBBackEndFacade;

@class HYB2BService;
@class HYBCheckoutView;
@class HYBCart;

enum selectedPickerType {costCenterPicker, deliveryAddressPicker, deliveryMethodPicker};

@interface HYBCheckoutController : HYBViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate,UITextFieldDelegate, UIAlertViewDelegate> {
    int selectedPicker;
    int pickersSelections[3];       
    CGPoint actionCenter;
    BOOL orderFirstTry;
    BOOL termsAndConditionsAccepted;
}

@property  (nonatomic,  strong)  NSArray       *optionsArray;
@property  (nonatomic,  strong)  UIPickerView  *mainPickerView;

@end
