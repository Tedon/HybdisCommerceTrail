//
// HYBCart.m
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


#import <CocoaLumberjack/DDLog.h>
#import "HYBCart.h"
#import "NSArray+BlocksKit.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "HYBCartItem.h"
#import "NSObject+NSCoding.h"
#import "HYBConstants.h"


NSString * const CART_PAYMENTTYPE_ACCOUNT = @"ACCOUNT";

@implementation HYBCart

- (id)initWithParams:(NSDictionary *)params baseStoreUrl:(NSString *)baseStoreUrl {
    
    NSAssert([baseStoreUrl hyb_isNotBlank], @"Base store url must be provided to create a cart. "
            "The base store url is used to build up the image urls.");
    
    self = [super init];

    if (self) {
        self.status                       = CART_OK;

        self.code                         = [params valueForKey:@"code"];
        self.totalItems                   = [params valueForKeyPath:@"totalItems"];
        self.totalPrice                   = [params valueForKeyPath:@"totalPrice.value"];
        self.totalPriceFormatted          = [params valueForKeyPath:@"totalPrice.formattedValue"];
        self.subTotalFormatted            = [params valueForKeyPath:@"subTotal.formattedValue"];
        self.totalPriceWithTax            = [params valueForKeyPath:@"totalPriceWithTax.value"];
        self.totalPriceWithTaxFormatted   = [params valueForKeyPath:@"totalPriceWithTax.formattedValue"];
        self.totalTaxFormatted            = [params valueForKeyPath:@"totalTax.formattedValue"];
        self.deliveryCost                 = [params valueForKeyPath:@"deliveryCost.formattedValue"];
        self.deliveryCode                 = [params valueForKeyPath:@"deliveryMode.code"];
        self.orderDiscounts               = [params valueForKeyPath:@"orderDiscounts.value"];
        self.orderDiscountsFormattedValue = [params valueForKeyPath:@"orderDiscounts.formattedValue"];

        if ([[params valueForKeyPath:@"appliedOrderPromotions"] hyb_isNotBlank]) {
            self.orderDiscountsMessage = [[[params valueForKeyPath:@"appliedOrderPromotions"] firstObject] objectForKey:@"description"];
        }

        self.totalUnitCount = [params valueForKeyPath:@"totalUnitCount"];

        if ([[params valueForKeyPath:@"paymentType"] hyb_isNotBlank]) {
            self.paymentTypeCode =          [params valueForKeyPath:@"paymentType.code"];
            self.paymentDisplayName =   [params valueForKeyPath:@"paymentType.displayName"];
        } else {
            self.paymentTypeCode =      @"ACCOUNT";
            self.paymentDisplayName =   @"ACCOUNT PAYMENT";
        }

        NSArray *entries = [params valueForKeyPath:@"entries"];
        if ([entries hyb_isNotBlank]) {
            NSMutableArray *itemsHolder = [NSMutableArray arrayWithCapacity:entries.count];
            [entries bk_each:^(NSDictionary *params) {
                HYBCartItem *item = [[HYBCartItem alloc] initWithParams:params baseStoreUrl:baseStoreUrl];
                [itemsHolder addObject:item];
            }];
            self.items = [NSArray arrayWithArray:itemsHolder];
        } else {
            self.items = [NSArray array];
        }
        
        if ([[params valueForKeyPath:@"appliedProductPromotions"] hyb_isNotBlank]) {
            NSArray *promotions = [params valueForKeyPath:@"appliedProductPromotions"];
            for (int i = 0; i < promotions.count; ++i) {
                NSDictionary *promotion = [promotions objectAtIndex:i];
                NSString *desc = [promotion objectForKey:@"description"];
                NSArray *consumedEntries = [promotion objectForKey:@"consumedEntries"];
                
                for (NSDictionary *entry in consumedEntries) {
                    
                    NSNumber *entryNumber = [entry objectForKey:@"orderEntryNumber"];
                    
                    if ([entryNumber intValue] < [self.items count]) {
                        HYBCartItem *cartItem = [self.items objectAtIndex:[entryNumber intValue]];
                        cartItem.discountMessage = [NSString stringWithString:desc];
                    } else {
                        //bug detected
                        self.status = CART_BAD;
                        DDLogError(@"Cart in a wrong state, back end delivered wrong data.");
                        break;
                    }
                }
            }
        }
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

- (BOOL)isEmpty {
    return [[self totalUnitCount] intValue] == 0;
}
@end