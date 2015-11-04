//
// HYBProductVariantOption.h
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

/**
* The class representing a a possible variant that exist for selection inside a product variant hirarchy.
* This class is used to model objects to represent an available variants set. Thats why a VariantOption
* only holds the basic information to represent an available selectable option.
*/
@interface HYBProductVariantOption : NSObject

@property(nonatomic, readonly) NSString *code;
@property(nonatomic, readonly) NSString *categoryName;
@property(nonatomic, readonly) NSString *categoryValue;
@property(nonatomic, readonly) NSArray  *variants;
@property(nonatomic, readonly) NSArray  *images;

/**
 *  init product variant
 *
 *  @param params variant as a NSDictionary
 *
 *  @return HYBProductVariantOption object
 */
- (id)initWithParams:(NSDictionary *)params;

/**
 *  returns variant dimensions number
 *
 *  @return int dimensions
 */
- (int)variantDimensionsNumber;

@end