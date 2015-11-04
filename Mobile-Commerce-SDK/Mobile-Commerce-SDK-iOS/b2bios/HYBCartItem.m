//
// HYBCartItem.m
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


#import <AutoNSCoding/NSObject+NSCoding.h>
#import "HYBCartItem.h"
#import "HYBProduct.h"
#import "NSObject+HYBAdditionalMethods.h"


@implementation HYBCartItem

- (id)initWithParams:(NSDictionary *)params baseStoreUrl:(NSString *)baseStoreUrl {
    NSAssert([baseStoreUrl hyb_isNotBlank], @"Base store url must be provided to create a cart. "
            "The base store url is used to build up the image urls.");

    self = [super init];

    if (self) {
        NSAssert([[params valueForKeyPath:@"product"] hyb_isNotBlank], @"Product was not given as part of the cart item entry. "
                "Product must exist inside the params.");

        self.product = [[HYBProduct alloc] initAsCartProductWithParams:[params valueForKeyPath:@"product"]
                                                          baseStoreUrl:baseStoreUrl];

        self.entryNumber = [params valueForKeyPath:@"entryNumber"];
        self.quantity = [params valueForKeyPath:@"quantity"];
        self.totalPriceFormattedValue = [params valueForKeyPath:@"totalPrice.formattedValue"];
        self.price = [params valueForKeyPath:@"basePrice.value"];
        self.basePriceFormattedValue = [params valueForKeyPath:@"basePrice.formattedValue"];
    }
    return self;
}

#pragma NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)encoder {
    [self encodeAutoWithCoder:encoder class:[self class]];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        [self decodeAutoWithAutoCoder:decoder class:[self class]];
    }
    return self;
}

- (NSDictionary *)asDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.entryNumber ,@"entryNumber",
            self.quantity, @"quantity",
            self.product.asDictionary, @"product",
            self.basePriceFormattedValue, @"basePriceFormattedValue",
            self.totalPriceFormattedValue, @"totalPriceFormattedValue",
            self.discountMessage, @"discountMessage",
            nil];
}
@end