//
// HYBBarButtonItem.m
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

#import "HYBBarButtonItem.h"

@implementation HYBBarButtonItem

- (void)setBadgeValue:(NSString *)badgeValue {
    [super setBadgeValue:badgeValue];
    
    if(self.customView && [[self.customView subviews] count] > 0) {        
        for (id view in [self.customView subviews]) {
            if([view isKindOfClass:[UILabel class]]) {
                UILabel *badge = (UILabel*)view;
                badge.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_CART_TOTAL";
                break;
            }
        }
    }
}

@end
