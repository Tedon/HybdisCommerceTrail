//
// HYBButton.h
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

static CGFloat primButtonHeight    = 60;
static CGFloat secButtonHeight     = 50;
static CGFloat defaultButtonWidth  = 215;
static CGFloat defaultCheckboxSize = 32;

typedef NS_ENUM(NSInteger, HYBButtonType) {
    HYBButtonTypePrimary   = 0,
    HYBButtonTypeSecondary = 1,
    HYBButtonTypeDropdown  = 2,
    HYBButtonTypeLink      = 3,
    HYBButtonTypeCheckbox  = 4
};

/**
* Class directly extending UIButton to add some utility methods but to keep the basic button functionality.
*/
@interface HYBButton : UIButton

+ (int)primaryButtonHeight;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

- (instancetype)initWithPosition:(CGPoint)position appendAtSuperView:(UIView *)superView title:(NSString *)title;

- (void)layoutAs:(enum HYBButtonType)layoutType;
@end