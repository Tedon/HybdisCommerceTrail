//
// HYBOrder.m
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


#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "HYBOrder.h"
#import "HYBAddress.h"
#import "HYBDeliveryMode.h"


@implementation HYBOrder

// JSON response values
//        "code": "00004772",
//        "guid": "e157c8e2c42195d31eca2e5e11a10609e19ab62f",
//        "placed": "2014-08-15T01:09:46-0400",
//        "status": "APPROVED",
//        "statusDisplay": "approved",
//        "total": {
//            "currencyIso": "USD",
//                    "formattedValue": "$48.99",
//                    "priceType": "BUY",
//                    "value": 48.99
//        }

//"deliveryAddress": {
//    "country": {
//        "isocode": "US"
//    },
//    "firstName": "Akiro",
//            "formattedAddress": "999 South Wacker Drive, Chicago, 60606",
//            "id": "8796153151511",
//            "lastName": "Nakamura",
//            "line1": "999 South Wacker Drive",
//            "postalCode": "60606",
//            "town": "Chicago"
//}
//
//"deliveryMode": {
//    "code": "standard-net",
//            "deliveryCost": {
//        "currencyIso": "USD",
//                "formattedValue": "$9.99",
//                "priceType": "BUY",
//                "value": 9.99
//    },
//    "description": "3-5 business days",
//            "name": "Standard Delivery Mode"
//}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"code" : @"code",
            @"status" : @"status",
            @"total" : @"totalPriceWithTax.formattedValue",
            @"deliveryAddress" : @"deliveryAddress",
            @"deliveryMode" : @"deliveryMode"
    };
}

+ (NSValueTransformer *)deliveryAddressJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:HYBAddress .class];
}

+ (NSValueTransformer *)deliveryModeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:HYBDeliveryMode .class];
}

@end