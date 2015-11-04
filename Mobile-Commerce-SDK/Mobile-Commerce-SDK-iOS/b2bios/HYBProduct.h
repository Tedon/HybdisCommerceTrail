//
// HYBProduct.h
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

static NSString *const galleryImageTypeKey = @"GALLERY";

/**
* The class representing a product. Products usually exist inside categories.
*/
@interface HYBProduct : NSObject <NSCoding>

@property(nonatomic, copy)  NSString        *name;
@property(nonatomic, copy)  NSString        *code;
@property(nonatomic, copy)  NSString        *desc;
@property(nonatomic, copy)  NSString        *summary;
@property(nonatomic, copy)  NSString        *formattedPrice;
@property(nonatomic, copy)  NSString        *priceRange;
@property(nonatomic, copy)  NSNumber        *price;
@property(nonatomic, copy)  NSString        *basePriceFormattedValue;
@property(nonatomic, copy)  NSString        *currencyIso;
@property(nonatomic, copy)  NSString        *thumbnailURL;
@property(nonatomic, copy)  NSString        *imageURL;
@property(nonatomic, copy)  NSString        *baseStoreURL;
@property(nonatomic, copy)  NSArray         *variants;
@property(nonatomic, copy)  NSNumber        *stock;
@property(nonatomic, copy)  NSMutableArray  *galleryImagesData;
@property(nonatomic, copy)  NSArray         *volumePricingData;
@property(nonatomic, copy)  NSString        *currencySign;

@property(nonatomic) BOOL lowStock;
@property(nonatomic) BOOL multidimensional;


/**
 *  init new product from dictionary
 *
 *  @param attributes   NSDictionary
 *  @param baseStoreUrl NSString
 *
 *  @return HYBProduct object
 */
- (id)initWithParams:(NSDictionary *)attributes baseStoreUrl:(NSString *)baseStoreUrl;

/**
 *  init new product from dictionary
 *
 *  @param attributes   NSDictionary
 *  @param baseStoreUrl NSString
 *
 *  @return HYBProduct object
 */
- (id)initAsCartProductWithParams:(NSDictionary *)params baseStoreUrl:(NSString *)baseStoreURL;

/**
 *  returns product name and formatted price
 *
 *  @return NSString label
 */
- (NSString *)label;

/**
 *  return url to the thumbnail image of the product
 *
 *  @return NSString URL
 */
- (NSString *)fullThumbnailURL;

/**
 *  add partUrl to baseStoreUrl
 *
 *  @param partUrl filename
 *
 *  @return NSString URL
 */
- (NSString *)createFullUrlFromPartUrl:(NSString *)partUrl;

/**
 *  check stock level for product
 *
 *  @return BOOL isInStock;
 */
- (BOOL)isInStock;

/**
 *  returns reviews as string
 *
 *  @return default review //not supported by server yet
 */
- (NSString *)reviews;

/**
 *  returns delivery details as string
 *
 *  @return default delivery details //not supported by server yet
 */
- (NSString *)deliveryDetails;

/**
 *  check if product is using volume pricing
 *
 *  @return BOOL isVolumePricingPresent
 */
- (BOOL)isVolumePricingPresent;

/**
 *  returns product pricing for object at index from volumePricingData array
 *
 *  @param index int
 *
 *  @return NSString formatted price Value
 */
- (NSString *)pricingValueForItemAtIndex:(int)index;

/**
 *  returns product code of first product variant
 *
 *  @return NSString code
 */
- (NSString *)firstVariantCode;

/**
 *  returns quantity value for object at index from volumePricingData array
 *
 *  @param index int
 *
 *  @return NSString quantity
 */
- (NSString *)quantityValueForItemAtIndex:(int)index;

/**
 *  returns number of dimension if product has variants else returns 0
 *
 *  @return int number of dimensions
 */
- (int)variantDimensionsNumber;

/**
 *  returns product as a NSDictionary
 *
 *  @return NSDictionary params
 */
- (NSDictionary *)asDictionary;
@end
