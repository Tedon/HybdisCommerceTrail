//
// HYBLoginView.m
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

#import <GRKGradientView/GRKGradientView.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <ClassyLiveLayout/UIView+ClassyLayoutProperties.h>
#import <UIKit/UIKit.h>
#import "SHPAbstractView.h"
#import "HYBLoginView.h"
#import "UIColor+HexString.h"
#import "NSArray+MASAdditions.h"
#import "View+MASShorthandAdditions.h"
#import "UIView+CASAdditions.h"
#import "UIView+HYBBase.h"
#import "HYBConstants.h"
#import "HYBButton.h"
#import "UIButton+HYBButton.h"


@implementation HYBLoginView {
    NSArray *_verticalLayoutViews;
}

/**
 *  generate view layout
 */
- (void)addSubviews {
    [self createBackGroundGradient];
    [self addSubview:self.gradientView];

    _logoView = [self createLogoView];
    
    _userName = [[UITextField alloc] init];
    _userName.cas_styleClass = @"primaryTextfield groupBegin";
    _userName.borderStyle = UITextBorderStyleRoundedRect;
    _userName.placeholder = NSLocalizedString(@"login_view_username_placeholder", @"Username or Email");
    _userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _userName.accessibilityIdentifier = @"ACCESS_LOGIN_TEXTFIELD_USER";
    [_userName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_userName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_userName setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_userName setKeyboardType:UIKeyboardTypeEmailAddress];
    [_userName setReturnKeyType:UIReturnKeyNext];
     
    _password = [[UITextField alloc] init];
    _password.cas_styleClass = @"primaryTextfield";
    _password.borderStyle = UITextBorderStyleRoundedRect;
    _password.placeholder = NSLocalizedString(@"login_view_password_placeholder", @"Password");
    _password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _password.secureTextEntry = YES;
    [_password setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_password setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_password setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_password setReturnKeyType:UIReturnKeyGo];
    _password.accessibilityIdentifier = @"ACCESS_LOGIN_TEXTFIELD_PASSWORD";

    _loginButton = [[HYBButton alloc] initWithStyleClassId:@"primaryButton disabled groupBegin" title:NSLocalizedString(@"login_view_sign_in", @"Sign In")];
    _loginButton.accessibilityIdentifier = @"ACCESS_LOGIN_BUTTON_LOGIN";
    _loginButton.enabled = NO;
    
    _verticalLayoutViews = @[self.logoView, self.userName, self.password, self.loginButton];

    [_verticalLayoutViews bk_each:^(UIView *subView) {
        [self addSubview:subView];
    }];
}
- (void)defineLayout {
    [self layoutSubviewsVertically];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradientView.frame = self.bounds;
}
#pragma mark Separate Field Creations
- (void)createBackGroundGradient {
    _gradientView = [[GRKGradientView alloc] init];
    _gradientView.gradientOrientation = GRKGradientOrientationDown;
    _gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    //TODO try to move to stylesheet
    UIColor *fromColor = [UIColor colorWithHexString:@"#013b7f"];
    UIColor *toColor = [UIColor colorWithHexString:@"#1c569a"];
    _gradientView.gradientColors = [NSArray arrayWithObjects:fromColor, toColor, nil];
}
- (UIImageView *)createLogoView {
    UIImageView *imageHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_logo.png"]];
    imageHolder.contentMode = UIViewContentModeScaleAspectFit;
    
    return imageHolder;
}

@end