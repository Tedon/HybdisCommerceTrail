//
// UILabel+HYBLabel.m
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
#import "UILabel+HYBLabel.h"
#import "UIView+CASAdditions.h"


@implementation UILabel (HYBLabel)

- (instancetype)initWithStyleClassId:(NSString *)styleClassId text:(NSString *)text {
    self = [[UILabel alloc] init];
    if (self) {
        [self setText:text];
        self.cas_styleClass = styleClassId;
    }
    return self;
}
@end