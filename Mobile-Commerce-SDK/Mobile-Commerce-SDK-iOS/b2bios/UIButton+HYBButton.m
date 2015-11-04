//
// UIButton+HYBButton.m
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

#import <ColorUtils/ColorUtils.h>
#import "UIButton+HYBButton.h"
#import "UIView+CASAdditions.h"
#import "UIView+HYBBase.h"

NSString *expandedStyleClassId = @"expanded";

@implementation UIButton (HYBButton)
- (instancetype)initWithStyleClassId:(NSString *)styleSheetId title:(NSString *)title {
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.cas_styleClass = styleSheetId;
        [self setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self layoutSubviewsHorizontally];
}

- (void)layoutAsDropdownButton {
    //unfortunately its not possible to configure it through the styleSheetId yet, since classy is not supporting it
    [[self layer] setBorderWidth:1.0f];
    [[self layer] setBorderColor:[[UIColor alloc] initWithString:@"#b8bec8"].CGColor];
    [self setTitleColor:[[UIColor alloc] initWithString:@"#b8bec8"] forState:UIControlStateNormal];
    
    //UIImageView *icon = [self createDropdownIconView];
    //[self addSubview:icon];
    
}

- (UIImageView *)createDropdownIconView {
    UIImageView *imageHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdown_icon.png"]];
    return imageHolder;
}

@end