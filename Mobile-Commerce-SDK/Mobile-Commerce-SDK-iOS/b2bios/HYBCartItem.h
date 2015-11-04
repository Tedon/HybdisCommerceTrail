//
// HYBCartItem.h
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

@class HYBProduct;

/**
* The class representing a cart item which is used inside a cart.
*/
@interface HYBCartItem : NSObject <NSCoding>

@property(nonatomic, strong) NSNumber   *entryNumber;
@property(nonatomic, strong) HYBProduct *product;
@property(nonatomic, strong) NSNumber   *quantity;
@property(nonatomic, strong) NSString   *totalPriceFormattedValue;
@property(nonatomic, strong) NSNumber   *price;
@property(nonatomic, strong) NSString   *basePriceFormattedValue;
@property(nonatomic, strong) NSString   *discountMessage;


/**
 *  init cart item : product with quantity, entry number, calculated prices, ...
 *
 *  @param params       cart item as a NSDictionary
 *  @param baseStoreUrl NSString url
 *
 *  @return HYBCartItem object
 */
- (id)initWithParams:(NSDictionary *)params baseStoreUrl:(NSString *)baseStoreUrl;

/**
 *  returns cart item as a NSDictionary
 *
 *  @return NSDictionary cart item
 */
- (NSDictionary *)asDictionary;

@end