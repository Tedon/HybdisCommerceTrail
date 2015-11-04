//
// HYBUser.m
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

#import "HYBUser.h"


@implementation HYBUser {
    NSDictionary *_attributes;
}
- (id)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        BOOL isValidUserData = [params valueForKeyPath:@"username"] != nil && [params valueForKeyPath:@"token"] != nil;
        if (isValidUserData) {
            _attributes = params;
        } else {
            NSString *reason = @"Not valid user data, please provide a minimum set of valid attributes.";
            @throw [[NSException alloc] initWithName:@"InitException" reason:reason userInfo:nil];
        }
    }
    return self;
}

- (NSString *)username {
    return [_attributes valueForKey:@"username"];
}
@end