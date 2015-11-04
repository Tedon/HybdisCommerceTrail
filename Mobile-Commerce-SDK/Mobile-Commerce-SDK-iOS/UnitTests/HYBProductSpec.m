//
// ProductListSpecificProductSpec.m
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

#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <RMMapper/NSUserDefaults+RMSaveCustomObject.h>
#import "HYBProduct.h"
#import "HYB2BService.h"
#import "HYBAppDelegate.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "HYBProductVariantOption.h"
#import "HYBCart.h"
#import "HYBCartItem.h"

SpecBegin(HYB2BProduct)
        describe(@"ProductListSpecificProduct", ^{

        __block NSString *baseStoreUrl;

        __block HYBProduct *product;
        __block HYBProduct *productLowStock;
        __block HYBProduct *productInStock;

        beforeAll(^{
            [DDLog addLogger:[DDASLLogger sharedInstance]];
            [DDLog addLogger:[DDTTYLogger sharedInstance]];

            NSString *prodListFilePath = [[NSBundle mainBundle] pathForResource:@"productListSampleResponse"
                                                                         ofType:@"json"];

            NSData *prodcutListData = [NSData dataWithContentsOfFile:prodListFilePath];

            NSDictionary *fullJSON = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:prodcutListData
                                                                                     options:kNilOptions
                                                                                       error:nil];

            HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
            baseStoreUrl= [b2bService baseStoreUrl];

            product = [[HYBProduct alloc] initWithParams:[[fullJSON valueForKeyPath:@"products"] firstObject] baseStoreUrl:baseStoreUrl];
            productLowStock = [[HYBProduct alloc] initWithParams:[[fullJSON valueForKeyPath:@"products"] lastObject] baseStoreUrl:baseStoreUrl];
            productInStock = [[HYBProduct alloc] initWithParams:[[fullJSON valueForKeyPath:@"products"] objectAtIndex:1] baseStoreUrl:baseStoreUrl];

            expect(product).to.beTruthy();
        });

        beforeEach(^{
        });

        it(@"should init a product from product list json", ^{
            expect(product.code).to.beTruthy();
            expect(product.summary).to.beTruthy();
            expect(product.desc).to.beTruthy();
            expect(product.thumbnailURL).to.beTruthy();
        });
        it(@"should retrieve the stock information no stock", ^{
            expect(product.isInStock).to.beFalsy();
        });
        it(@"should retrieve the stock information low stock", ^{
            expect(productLowStock.isInStock).to.beTruthy();
            expect(productLowStock.lowStock).to.beTruthy();
        });
        it(@"should retrieve the stock information in stock", ^{
            expect(productInStock.isInStock).to.beTruthy();
            // in stock but no stock data since in the list view
            int stock = productInStock.stock.intValue;
            expect(stock).to.equal(-1);
        });
        it(@"should recognize a multi-d product", ^{
            expect(product.multidimensional).to.beTruthy();
        });

        it(@"should have the firstVariantCode", ^{
            expect(product.firstVariantCode).to.beTruthy();
        });
        it(@"should have the currency data", ^{
            expect(product.currencyIso).to.equal(@"USD");
            expect(product.currencySign).to.equal(@"$");

        });
        it(@"should give a price range if multi-d product", ^{
            expect(product.price).to.equal(85);
            expect(product.formattedPrice).to.equal(@"$85.00-$97.00");
            expect(product.priceRange).to.equal(@"$85.00-$97.00");
        });
    });

    describe(@"ProductDetailsSpecificProduct", ^{
            __block NSDictionary *json;
            __block HYBProduct *product;
            __block NSString *baseStoreUrl;

            beforeAll(^{
                [DDLog addLogger:[DDASLLogger sharedInstance]];
                [DDLog addLogger:[DDTTYLogger sharedInstance]];

                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"productByIdSampleResponse" ofType:@"json"];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                       options:kNilOptions
                                                                         error:nil];

                HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
                baseStoreUrl= [b2bService baseStoreUrl];
            });

            beforeEach(^{
                product = [[HYBProduct alloc] initWithParams:json baseStoreUrl:baseStoreUrl];
                expect(product).to.beTruthy();
            });

            it(@"should init a product from details page json", ^{
                expect(product.desc).to.beTruthy();
                expect(product.price).to.beTruthy();
                expect(product.thumbnailURL).to.beTruthy();
            });


            it(@"should list all images", ^{
                expect(product.imageURL).to.beTruthy();
                expect(product.galleryImagesData).to.beTruthy();
                expect([product.galleryImagesData count] > 0);

                int numberOfGalleryImages = 3;
                expect(product.galleryImagesData).to.haveCountOf(numberOfGalleryImages);

                expect([[product.galleryImagesData firstObject] objectForKey:@"imageType"]).to.equal(galleryImageTypeKey);
            });

            it(@"should retrieve the stock", ^{
                expect([product stock] > 0).to.beTruthy();
                expect([product isInStock]).to.beTruthy();
            });

            it(@"should retrieve the summary", ^{
                NSString *summary = product.summary;
                expect(summary).to.beTruthy();
            });

            it(@"should retrieve the price", ^{
                expect([[product price] floatValue]).to.beTruthy();
            });

            it(@"should retrieve formatted price", ^{
                NSString *formattedPrice = product.formattedPrice;
                expect(formattedPrice).to.beTruthy();
            });

            it(@"should retrieve currency iso", ^{
                NSString *currency = product.currencyIso;
                expect(currency).to.beTruthy();
            });

            it(@"should provide volume pricing data", ^{
                NSArray *volumePrices = [product volumePricingData];
                expect(volumePrices).to.beTruthy();
                expect([volumePrices count] == 5).to.beTruthy();
                NSDictionary *firstPricingItem = [volumePrices firstObject];
                expect(firstPricingItem).to.beTruthy();
                expect([firstPricingItem objectForKey:@"currencyIso"]).to.equal(@"USD");
                expect([firstPricingItem objectForKey:@"maxQuantity"]).to.beKindOf([NSNumber class]);
                expect([firstPricingItem objectForKey:@"minQuantity"]).to.beKindOf([NSNumber class]);
            });
            it(@"should provide pricing and quantity for item at given index", ^{
                NSString *pricing = [product pricingValueForItemAtIndex:0];
                NSString *qty = [product quantityValueForItemAtIndex:0];

                expect(pricing).to.equal(@"$16.00");
                expect(qty).to.equal(@"1-9");
            });
           it(@"should create multi-d variants tree", ^{
               NSArray *variants = [product variants];
               expect(variants).to.beTruthy();
               expect([variants count]).to.equal(3);
           });
            it(@"should calculate number of dimensions", ^{
                int actual = product.variantDimensionsNumber;
                expect(actual).to.equal(3);

                NSArray *variants = [product variants];
                HYBProductVariantOption *variant = [variants firstObject];
                int childDimNumber = variant.variantDimensionsNumber;
                expect(childDimNumber).to.equal(3);

                HYBProductVariantOption *secondDimVariant = [[variant variants] firstObject];
                int secDimNumber = secondDimVariant.variantDimensionsNumber;
                expect(secDimNumber).to.equal(2);
            });
            it(@"should create a proper product variant option in the tree", ^{
                NSArray *variants = [product variants];

                HYBProductVariantOption *variant = [variants firstObject];

                NSString *code = variant.code;
                NSString *categoryName = variant.categoryName;
                NSString *categoryValue = variant.categoryValue;

                expect(code).to.beTruthy();
                expect(categoryName).to.beTruthy();
                expect(categoryValue).to.beTruthy();

                NSArray *subVariants = variant.variants;
                expect(subVariants).to.beTruthy();
                expect([subVariants count]).to.equal(2);

                NSArray *images = variant.images;
                expect(images).to.beTruthy();
                expect([images count]).to.equal(5);

                HYBProductVariantOption *subVariant = [subVariants firstObject];
                expect(subVariant.code).to.beTruthy();
                expect(subVariant.categoryName).to.beTruthy();
                expect(subVariant.categoryValue).to.beTruthy();
            });
    });
    describe(@"CartItemProduct", ^{
        __block NSDictionary *json;
        __block HYBCart *cart;

        beforeAll(^{
            [DDLog addLogger:[DDASLLogger sharedInstance]];
            [DDLog addLogger:[DDTTYLogger sharedInstance]];

            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"presentCartSampleResponse" ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];

            json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            cart = [[HYBCart alloc] initWithParams:json baseStoreUrl:@"http://random.com"];
        });
        it(@"should create the product on the cart item", ^{
            HYBCartItem *item = cart.items.firstObject;
            HYBProduct *p = item.product;
            expect(p).to.beTruthy();
            expect(p.code).to.beTruthy();
            expect(p.name).to.beTruthy();
            expect(p.thumbnailURL).to.beTruthy();
            expect(p.fullThumbnailURL).to.beTruthy();
        });
        it(@"should create the product on the cart item", ^{
            HYBCartItem *item = cart.items.firstObject;
            HYBProduct *p = item.product;
            expect(p.code).to.beTruthy();
            expect(p.name).to.beTruthy();

            expect(p.asDictionary).to.beTruthy();
        });
        it(@"should save and retrieve the whole cart to archive", ^{
            HYBCartItem *item = cart.items.firstObject;
            HYBProduct *product = item.product;
            expect(product.asDictionary).to.beTruthy();
            NSString *productKey = @"mySavedProduct";
            NSUserDefaults *cache = [[NSUserDefaults alloc] init];
            [cache rm_setCustomObject:product forKey:productKey];
            HYBProduct *retrievedProduct = [cache rm_customObjectForKey:productKey];
            expect(retrievedProduct).to.beTruthy();
            expect(retrievedProduct.name).to.beTruthy();
            expect(retrievedProduct.code).to.beTruthy();
            expect(retrievedProduct.thumbnailURL).to.beTruthy();
            [cache removeObjectForKey:productKey];
        });
    });
SpecEnd
