//
// HYBLoginView.h
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

@class HYBButton;
@class GRKGradientView;
@class UITextField;
@class UIButton;
@class UIView;

@interface HYBLoginView : SHPAbstractView

@property(nonatomic)  UITextField      *userName;
@property(nonatomic)  UITextField      *password;
@property(nonatomic)  UIButton         *loginButton;
@property(nonatomic)  UIView           *logoView;
@property(nonatomic)  GRKGradientView  *gradientView;

@end