//
// HYBAddress.m
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


#import "HYBAddress.h"
#import "MTLModel.h"

@implementation HYBAddress

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"firstName"        : @"firstName",
            @"lastName"         : @"lastName",
            @"id"               : @"id",
            @"line1"            : @"line1",
            @"postalCode"       : @"postalCode",
            @"shippingAddress"  : @"shippingAddress",
            @"title"            : @"title",
            @"email"            : @"email",
            @"town"             : @"town",
            @"formattedAddress" : @"formattedAddress",
            @"countryName"      : @"country.name",
            @"countryIso"       : @"country.isocode"
    };
}


- (NSString *)formattedAddressBreakLines {
    return [self.formattedAddress stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
}

@end