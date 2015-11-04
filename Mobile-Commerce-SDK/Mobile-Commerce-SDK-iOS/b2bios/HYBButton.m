//
// HYBButton.m
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

#import <BlocksKit/NSArray+BlocksKit.h>
#import "HYBButton.h"
#import "ColorUtils.h"
#import "UIView+CASAdditions.h"

@implementation HYBButton {
    UIColor *borderMain;
    UIColor *textMain;
    UIColor *backGroundButtonMain;
    UIColor *backGroundSecondary;
    UIColor *backGroundButtonSecondary;
    UIColor *backGroundButtonDropdown;
    UIColor *backGroundMain;
}

+ (int)primaryButtonHeight {
    return primButtonHeight;
}

+ (int)secondaryButtonHeight {
    return secButtonHeight;
}

- (instancetype)initWithPosition:(const CGPoint)position appendAtSuperView:(UIView *)superView title:(NSString *)title {
    self = [HYBButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        [self initColors];
        self.frame = CGRectMake(position.x, position.y, superView.bounds.size.width - position.x * 2, primButtonHeight);
        [superView addSubview:self];
        [self setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (instancetype)initWithStyleClassId:(NSString *)styleSheetId title:(NSString *)title {
    self = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if (self) {
        self.cas_styleClass = styleSheetId;
        [self setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (void)initColors {
    textMain                  = [[UIColor alloc] initWithString:@"#0054AE"];

    backGroundButtonMain      = [[UIColor alloc] initWithString:@"#FAD712"];
    backGroundButtonSecondary = [[UIColor alloc] initWithString:@"#B8BEC8"];
    backGroundButtonDropdown  = [[UIColor alloc] initWithString:@"#FFFFFF"];

    backGroundMain            = [[UIColor alloc] initWithString:@"#FFFFFF"];
    backGroundSecondary       = [[UIColor alloc] initWithString:@"#EEEEEE"];

    borderMain                = [[UIColor alloc] initWithString:@"#D3D6DB"];
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [HYBButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.frame = frame;
        [self initColors];
        [self setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutAsPrimaryButton {
    [self layoutWithBackground:backGroundButtonMain
                   borderWidth:0.0
                     textColor:textMain
                   borderColor:nil];
}


- (void)layoutAsSecondaryButton {
    self.frame = CGRectMake(0, 0, defaultButtonWidth, secButtonHeight);
    [self layoutWithBackground:backGroundButtonSecondary
                   borderWidth:1.0
                     textColor:textMain
                   borderColor:borderMain];
}


- (void)layoutAsDropdownButton {
    self.frame = CGRectMake(0, 0, defaultButtonWidth, secButtonHeight);

    [self layoutWithBackground:backGroundButtonDropdown borderWidth:1 textColor:textMain borderColor:borderMain];

    UIImageView *imageHolder = [self createDropdownIconView];

    [self addSubview:imageHolder];
}

- (void)layoutAsLinkButton {
    self.frame = CGRectMake(0, 0, defaultButtonWidth, secButtonHeight);

    [self layoutWithBackground:backGroundButtonDropdown
                   borderWidth:0.0
                     textColor:textMain
                   borderColor:borderMain];
}

-(void)layoutAsCheckboxButton {
    self.frame = CGRectMake(0, 0, defaultCheckboxSize, defaultCheckboxSize);
    
    [self layoutWithBackground:backGroundButtonDropdown
                   borderWidth:0.0
                     textColor:nil
                   borderColor:nil];
}

- (void)expand {
    [self layoutWithBackground:backGroundSecondary
                   borderWidth:0.0
                     textColor:textMain
                   borderColor:borderMain];

    UIImageView *imageHolder = [self createDropdownIconView];

    [self addSubview:imageHolder];
}

- (void)collapse {
    [self layoutWithBackground:backGroundButtonDropdown
                   borderWidth:0.0
                     textColor:textMain
                   borderColor:borderMain];

    NSArray *imageSubviews = [self.subviews bk_select:^BOOL(UIView *view) {
        return [view isKindOfClass:[UIImageView class]];
    }];

    [imageSubviews bk_each:^(UIView *view) {
        [view removeFromSuperview];
    }];
}

- (UIImageView *)createDropdownIconView {

    UIImageView *imageHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdown_icon.png"]];

    int scaledImageSize = 25;
    CGFloat imageX = CGRectGetMaxX(self.bounds) - scaledImageSize - 10;
    CGFloat imageY = CGRectGetMinY(self.bounds) + [self buttonSizeDependentPaddingTop];

    imageHolder.frame = CGRectMake(imageX, imageY, scaledImageSize, scaledImageSize);
    imageHolder.contentMode = UIViewContentModeScaleAspectFit;
    return imageHolder;
}

- (void)layoutWithBackground:(UIColor *)backGround borderWidth:(float)borderWidth textColor:(UIColor *)textColor borderColor:(UIColor *)borderColor {

    [self setBackgroundColor:backGround];
    
    if (textColor)  [self setTitleColor:textColor forState:UIControlStateNormal];
    if (borderColor)[self.layer setBorderColor:borderColor.CGColor];
    
    [self.layer setBorderWidth:borderWidth];
}

- (int)buttonSizeDependentPaddingTop {
    return primButtonHeight * 0.25;
}

- (void)layoutAs:(enum HYBButtonType)layoutType {
    switch(layoutType)
    {
        case HYBButtonTypePrimary :
            [self layoutAsPrimaryButton];
            break;
        case HYBButtonTypeSecondary :
            [self layoutAsSecondaryButton];
            break;
        case HYBButtonTypeDropdown :
            [self layoutAsDropdownButton];
            break;
        case HYBButtonTypeLink :
            [self layoutAsLinkButton];
        case HYBButtonTypeCheckbox :
            [self layoutAsCheckboxButton];
            break;
        default : {
            NSString *reason = [NSString stringWithFormat:@"The provided layout type  %d for the button is not supported. \nPlease use only the types from %@", (int)layoutType, [HYBButton class]];

            @throw([NSException exceptionWithName:@"WrongArgumentException" reason:reason userInfo:nil]);
        }
    }
}
@end
