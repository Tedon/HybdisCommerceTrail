//
// HYBDeliveryMode.m
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


#import "HYBDeliveryMode.h"


@implementation HYBDeliveryMode

//"deliveryMode": {
//    "code": "standard-net",
//    "deliveryCost": {
//        "currencyIso": "USD",
//        "formattedValue": "$9.99",
//        "priceType": "BUY",
//        "value": 9.99
//    },
//    "description": "3-5 business days",
//    "name": "Standard Delivery Mode"
//}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"code" : @"code",
            @"formattedValue" : @"deliveryCost.formattedValue",
            @"name" : @"name",
            @"fullDescription" : @"description"
    };
}

@end