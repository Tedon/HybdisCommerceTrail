//
// HYBCategorySpec.m
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
#import "HYBCategory.h"

SpecBegin(HYBCategory)
    describe(@"HYBCategory", ^{
        __block NSDictionary *json;
        __block HYBCategory *catRoot;

        beforeAll(^{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"categoriesSampleResponse" ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];

            json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            catRoot = [[HYBCategory alloc] initWithAttributesAsTree:json];
            expect(catRoot).to.beTruthy();
            expect([catRoot hasSubcategories]).to.beTruthy();
        });

        it(@"should create a category tree from json", ^{
            NSDictionary *attr = [[json objectForKey:@"subcategories"] firstObject];
            HYBCategory *category = [[HYBCategory alloc] initWithAttributes:attr parent:nil ];

            expect([category name]).to.beTruthy();
            expect([category id]).to.beTruthy();
            expect([category url]).to.beTruthy();
        });

        it(@"should create and recognize the root category", ^{
            expect([catRoot name]).to.equal([json objectForKey:@"name"]);
            expect([catRoot id]).to.equal([json objectForKey:@"id"]);
            expect([[catRoot subCategories] count] > 0).to.beTruthy();
            expect([catRoot isRoot]).to.beTruthy();
            expect([catRoot isLeaf]).to.beFalsy();
        });

        it(@"should create subcategories", ^{
            HYBCategory *firstSubCat = [[catRoot subCategories] firstObject];
            HYBCategory *lastSubCat = [[catRoot subCategories] lastObject];

            expect(firstSubCat).to.beTruthy();
            expect([firstSubCat isLeaf]).to.beFalsy();
            expect(lastSubCat).to.beTruthy();
            expect([lastSubCat isLeaf]).to.beFalsy();
        });

        it(@"should find a category in tree by id", ^{
            HYBCategory *firstSubCat = [[catRoot subCategories] firstObject];
            HYBCategory *firstChildSubcat = [[firstSubCat subCategories] firstObject];
            expect(firstChildSubcat).to.beTruthy();
            HYBCategory *foundCat = [catRoot findCategoryByIdInsideTree:[firstChildSubcat id]];
            expect(foundCat).to.equal(firstChildSubcat);
        });

        it(@"should link any category to its parent", ^{
            HYBCategory *firstSubCat = [[catRoot subCategories] firstObject];
            HYBCategory *firstChildSubcat = [[firstSubCat subCategories] firstObject];
            expect([firstChildSubcat parentCategory]).to.equal(firstSubCat);
            expect([firstSubCat parentCategory]).to.equal(catRoot);
        });
    });
SpecEnd
