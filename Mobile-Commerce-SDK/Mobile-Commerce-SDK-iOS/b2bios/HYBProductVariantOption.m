//
// HYBProductVariantOption.m
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


#import "HYBProductVariantOption.h"
#import "NSArray+BlocksKit.h"
#import "NSObject+HYBAdditionalMethods.h"


@implementation HYBProductVariantOption
- (id)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {

        _code = [params valueForKeyPath:@"variantOption.code"];
        _categoryName = [params valueForKeyPath:@"parentVariantCategory.name"];
        _categoryValue = [params valueForKeyPath:@"variantValueCategory.name"];

        BOOL isLeaf = [[params valueForKeyPath:@"isLeaf"] boolValue];

        if (!isLeaf) {
            NSArray *elements = [params valueForKeyPath:@"elements"];
            NSMutableArray *subVariants = [[NSMutableArray alloc] initWithCapacity:[elements count]];
            [elements bk_each:^(NSDictionary *params) {
                HYBProductVariantOption *var = [[HYBProductVariantOption alloc] initWithParams:params];
                [subVariants addObject:var];
            }];
            _variants = [[NSArray alloc] initWithArray:subVariants];
        }

        NSArray *imageData = [params valueForKeyPath:@"variantOption.variantOptionQualifiers"];
        if(imageData){
            NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:[imageData count]];
            [imageData bk_each:^(NSDictionary *data) {
                [images addObject:[data valueForKeyPath:@"image.url"]];
            }];
            _images = [[NSArray alloc] initWithArray:images];
        }
    }
    return self;
}

- (int)variantDimensionsNumber {
    if ([self.variants hyb_isNotBlank]) {
        return 1 + [[self.variants firstObject] variantDimensionsNumber];
    } else {
        return 1;
    }
}
@end