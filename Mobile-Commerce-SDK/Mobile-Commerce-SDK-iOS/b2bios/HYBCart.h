//
// HYBCart.h
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

#import <Foundation/Foundation.h>

#define CART_OK     @"CART_OK"
#define CART_BAD    @"CART_BAD"

extern NSString * const CART_PAYMENTTYPE_ACCOUNT;

/**
* The class representing an cart. This cart class can be used in any commerce domain.
*/
@interface HYBCart : NSObject <NSCoding>

@property(nonatomic, copy)  NSString  *status;
@property(nonatomic, copy)  NSString  *code;
@property(nonatomic, copy)  NSNumber  *totalItems;
@property(nonatomic, copy)  NSNumber  *totalPrice;
@property(nonatomic, copy)  NSString  *totalTaxFormatted;
@property(nonatomic, copy)  NSNumber  *totalPriceWithTax;
@property(nonatomic, copy)  NSNumber  *totalPriceWithTaxFormatted;
@property(nonatomic, copy)  NSNumber  *totalUnitCount;
@property(nonatomic, copy)  NSString  *totalPriceFormatted;
@property(nonatomic, copy)  NSString  *subTotalFormatted;
@property(nonatomic, copy)  NSArray   *items;
@property(nonatomic, copy)  NSNumber  *orderDiscounts;
@property(nonatomic, copy)  NSString  *orderDiscountsFormattedValue;
@property(nonatomic, copy)  NSString  *orderDiscountsMessage;
@property(nonatomic, copy)  NSString  *deliveryCost;
@property(nonatomic, copy)  NSString  *deliveryCode;
@property(nonatomic, copy)  NSString  *paymentTypeCode;
@property(nonatomic, copy)  NSString  *paymentDisplayName;

/**
 *  init a cart object
 *
 *  @param params       cart as a NSDictionary
 *  @param baseStoreUrl NSString url
 *
 *  @return HYBCart cart
 */
- (id)initWithParams:(NSDictionary *)params baseStoreUrl:(NSString *)baseStoreUrl;

/**
 *  returns BOOL out of cart total item count (count == 0 => empty cart)
 *
 *  @return bool is cart empty
 */
- (BOOL)isEmpty;
@end