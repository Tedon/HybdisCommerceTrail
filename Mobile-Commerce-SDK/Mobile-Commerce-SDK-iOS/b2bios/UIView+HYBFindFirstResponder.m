//
// UIView+FindFirstResponder.m
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

#import "UIView+HYBFindFirstResponder.h"

@implementation UIView (HYBFindFirstResponder)

- (UIView*)findFirstResponder {
    if (self.isFirstResponder) return self;
    
    for (UIView *subView in self.subviews) {
        UIView *responder = [subView findFirstResponder];
        if (responder) return responder;
    }
    
    return nil;
}

@end