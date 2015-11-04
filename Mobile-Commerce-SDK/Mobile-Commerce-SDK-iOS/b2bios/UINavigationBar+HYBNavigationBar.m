//
// UINavigationBar+HYBNavigationBar.m
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


#import "UINavigationBar+HYBNavigationBar.h"


@implementation UINavigationBar (HYBNavigationBar)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width, 60);
    return newSize;
}
@end