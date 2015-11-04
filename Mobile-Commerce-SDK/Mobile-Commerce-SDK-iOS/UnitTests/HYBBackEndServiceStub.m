//
// HYBBackEndServiceStub.m
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

#import <BlocksKit/NSArray+BlocksKit.h>
#import "HYBBackEndServiceStub.h"
#import "HYBCategory.h"
#import "NSObject+HYBAdditionalMethods.h"

@implementation HYBBackEndServiceStub {
    HYBCategory *catRoot;
    NSMutableArray *products;
}

- (id)initWithDefaults {

    self = [super initWithDefaults];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"categoriesSampleResponse" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    catRoot = [[HYBCategory alloc] initWithAttributesAsTree:json];

    NSAssert([catRoot hyb_isNotBlank], @"Categories root must be present in stub");
    NSAssert([[catRoot subCategories] hyb_isNotBlank], @"Subcategories must be present in stub");

    NSString *prodListFilePath = [[NSBundle mainBundle] pathForResource:@"productListSampleResponse"
                                                                 ofType:@"json"];

    NSData *prodcutListData = [NSData dataWithContentsOfFile:prodListFilePath];

    NSDictionary *fullJSON = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:prodcutListData
                                                                              options:kNilOptions
                                                                                error:nil];
    NSArray *productsAsJSON = [fullJSON valueForKeyPath:@"products"];
    products = [[NSMutableArray alloc] initWithCapacity:[productsAsJSON count]];
    [productsAsJSON bk_each:^(NSDictionary *obj) {
        HYBProduct *product = [[HYBProduct alloc] initWithParams:obj baseStoreUrl:@"http://somedomain.com:9001"];
        [products addObject:product];
    }];

    NSAssert([products hyb_isNotBlank], @"Products must exist.");
    HYBProduct *p = [products firstObject];
    NSAssert([p hyb_isNotBlank], @"Each product must exist.");
    NSAssert([[p code] hyb_isNotBlank], @"Each product must exist.");

    return self;
}

- (void)findCategoriesWithBlock:(void (^)(NSArray *, NSError *))block {
    block(@[catRoot], nil);
}

- (void)findProductsByCategoryId:(NSString *)categoryId withBlock:(void (^)(NSArray *foundCategories, NSError *error))block {
    block(products, nil);
}
@end