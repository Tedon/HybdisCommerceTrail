//
// HYBProduct.m
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


#import "HYBProduct.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "NSString+HYStringUtils.h"
#import "HYBProductVariantOption.h"
#import "HYBCart.h"
#import "NSObject+NSCoding.h"

@implementation HYBProduct {
    NSString *_firstVariantCode;
}

- (NSString *)label {
    return [[NSString alloc] initWithFormat:@"%@ for %@", self.name, self.formattedPrice];
}

- (id)initWithParams:(NSDictionary *)attributes baseStoreUrl:(NSString *)baseStoreUrl {
    NSAssert([baseStoreUrl hyb_isNotBlank], @"Base store url must be provided to create a cart. "
            "The base store url is used to build up the image urls.");

    if (self = [super init]) {
        [self initBaseAttributes:attributes baseStoreUrl:baseStoreUrl];

        [self initPriceRange:attributes];

        _currencyIso = [attributes valueForKeyPath:@"price.currencyIso"];

        _desc = [attributes valueForKeyPath:@"description"];
        _summary = [attributes valueForKeyPath:@"summary"];

        _galleryImagesData = [[NSMutableArray alloc] init];

        self.lowStock = NO;
        NSDictionary *stockData = [attributes valueForKeyPath:@"stock"];
        if (stockData) {
            NSString *stockLevel = [stockData valueForKeyPath:@"stockLevel"];
            NSString *stockCode = [stockData valueForKeyPath:@"stockLevelStatus"];

            if ([stockCode isEqualToString:@"outOfStock"]) {
                _stock = [NSNumber numberWithInt:0];
            } else if ([stockCode isEqualToString:@"lowStock"]) {
                _stock = [NSNumber numberWithInt:[stockLevel intValue]];
                _lowStock = YES;
            } else if ([stockCode isEqualToString:@"inStock"]) {
                if (stockLevel) {
                    _stock = [NSNumber numberWithInt:[stockLevel intValue]];
                } else {
                    // it is in stock but no concrete value provided
                    _stock = [NSNumber numberWithInt:-1];
                }
            }
        }

        NSArray *variantsData = [attributes valueForKeyPath:@"variantMatrix"];
        if (variantsData) {
            NSMutableArray *variants = [NSMutableArray arrayWithCapacity:[variantsData count]];
            [variantsData bk_each:^(NSDictionary *variantParams) {
                HYBProductVariantOption *variantOption = [[HYBProductVariantOption alloc] initWithParams:variantParams];
                [variants addObject:variantOption];
            }];
            _variants = [NSArray arrayWithArray:variants];
        } else {
            _variants = [NSArray array];
        }

        [self extractImagesFromParams:attributes];

        if (![_thumbnailURL hyb_isNotBlank] && [attributes valueForKeyPath:@"firstVariantImage"]) {
            _thumbnailURL = [attributes valueForKeyPath:@"firstVariantImage"];
        }

        _firstVariantCode = [attributes valueForKeyPath:@"firstVariantCode"];

        _volumePricingData = [[NSArray alloc] init];
        if ([attributes valueForKeyPath:@"volumePrices"]) {
            _volumePricingData = [attributes valueForKeyPath:@"volumePrices"];
        }
    }
    return self;
}

- (void)initPriceRange:(NSDictionary *)attributes {
    NSString *min = [attributes valueForKeyPath:@"priceRange.minPrice.formattedValue"];
    NSString *max = [attributes valueForKeyPath:@"priceRange.maxPrice.formattedValue"];

    if ([min hyb_isNotBlank] && [max hyb_isNotBlank]) {
        _priceRange = [NSString stringWithFormat:@"%@-%@", min, max];
        _formattedPrice = _priceRange;
    } else {
        _priceRange = _formattedPrice;
    }
}

- (id)initAsCartProductWithParams:(NSDictionary *)params baseStoreUrl:(NSString *)baseStoreUrl {
    NSAssert([baseStoreUrl hyb_isNotBlank], @"Base store url must be provided to create a cart. "
            "The base store url is used to build up the image urls.");

    self = [super init];
    if (self) {
        [self initBaseAttributes:params baseStoreUrl:baseStoreUrl];
        [self initPriceRange:params];
        [self extractImagesFromParams:params];
    }
    return self;
}

- (void)initBaseAttributes:(NSDictionary *)attributes baseStoreUrl:(NSString *)baseStoreUrl {
    _name = [attributes valueForKeyPath:@"name"];
    _code = [attributes valueForKeyPath:@"code"];
    _baseStoreURL = baseStoreUrl;

    _price = [attributes valueForKeyPath:@"price.value"];
    _formattedPrice = [attributes valueForKeyPath:@"price.formattedValue"];
    if ([_formattedPrice hyb_isNotBlank]) {
        _currencySign = [_formattedPrice substringFrom:0 to:1];
    }

    NSString *multidimensionalValue = [attributes valueForKeyPath:@"multidimensional"];
    if (multidimensionalValue) {
        _multidimensional = [multidimensionalValue boolValue];
    } else {
        _multidimensional = NO;
    }
}

- (void)extractImagesFromParams:(NSDictionary *)params {
    NSArray *images = [params valueForKeyPath:@"images"];

    [images bk_each:^(NSDictionary *image) {
        if ([self isImageInFormat:image imageFormat:@"thumbnail"]) {
            _thumbnailURL = [image objectForKey:@"url"];
        }
        if ([self isImageInFormat:image imageFormat:@"product"]) {
            _imageURL = [image objectForKey:@"url"];
        }
        if ([self isImageInType:image imageType:galleryImageTypeKey]) {
            [_galleryImagesData addObject:image];
        }
    }];

}

- (BOOL)isImageInType:(NSDictionary *)image imageType:(NSString *)type {
    return [image objectForKey:@"imageType"] && [[image objectForKey:@"imageType"] isEqualToString:type];
}

- (BOOL)isImageInFormat:(NSDictionary *)image imageFormat:(NSString *)imageFormat {
    return [image objectForKey:@"format"] && [[image objectForKey:@"format"] isEqualToString:imageFormat];
}

- (NSString *)fullThumbnailURL {
    return [self createFullUrlFromPartUrl:self.thumbnailURL];
}

- (NSString *)createFullUrlFromPartUrl:(NSString *)partUrl {
    if (partUrl) {
        return [_baseStoreURL stringByAppendingString:partUrl];
    } else {
        return [NSString string];
    }
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@ - %@>", _code, _name];

    [description appendString:@">"];
    return description;
}

- (BOOL)isInStock {
    int intStock = [_stock intValue];
    return ((intStock > 0) || (intStock == -1));
}

- (NSString *)deliveryDetails {
    return @"default_delivery_details";
}

- (NSString *)reviews {
    return @"default_reviews";
}

- (BOOL)isVolumePricingPresent {
    return [self.volumePricingData hyb_isNotBlank];
}

- (NSString *)pricingValueForItemAtIndex:(int)index {
    NSString *result = @"";
    if (self.isVolumePricingPresent) {
        NSDictionary *item = [self.volumePricingData objectAtIndex:index];
        result = [item objectForKey:@"formattedValue"];
    }
    return result;
}

- (NSString *)firstVariantCode {
    return [_firstVariantCode hyb_isNotBlank] ? _firstVariantCode : _code;
}

- (NSString *)quantityValueForItemAtIndex:(int)index {
    NSString *result = @"";
    if (self.isVolumePricingPresent) {
        NSDictionary *item = [self.volumePricingData objectAtIndex:index];
        NSString *minQuantity = [item objectForKey:@"minQuantity"];
        NSString *maxQuantity = [item objectForKey:@"maxQuantity"];
        result = [NSString stringWithFormat:@"%@-%@", minQuantity, maxQuantity];
    }
    return result;
}

- (int)variantDimensionsNumber {
    if ([self.variants hyb_isNotBlank]) {
        return [[self.variants firstObject] variantDimensionsNumber];
    } else {
        return 0;
    }
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
    NSArray *objects = @[self.name, self.code, self.baseStoreURL];
    NSArray *keys = @[@"name", @"code", @"baseStoreUrl"];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjects:objects
                                                                     forKeys:keys];
    if ([self.thumbnailURL hyb_isNotBlank]) {
        [result setObject:self.thumbnailURL forKey:@"thumbnailURL"];
    }
    if ([self.formattedPrice hyb_isNotBlank]) {
        [result setObject:self.formattedPrice forKey:@"formattedPrice"];
    }
    if (self.multidimensional) {
        [result setObject:[NSNumber numberWithBool:self.multidimensional] forKey:@"multidimensional"];
    }
    if (self.price) {
        [result setObject:self.price forKey:@"price"];
    }
    return [NSDictionary dictionaryWithDictionary:result];
}
@end
