//
// HYBCostCenterSpec.m
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
#import <RMMapper/NSUserDefaults+RMSaveCustomObject.h>
#import <BlocksKit/NSObject+BKAssociatedObjects.h>
#import "HYBCart.h"
#import "HYBCartItem.h"
#import "HYBProduct.h"
#import "HYBProductVariantOption.h"
#import "HYBCostCenter.h"
#import "HYBAddress.h"
#import "HYB2BService.h"

SpecBegin(HYBCostCenterSpec)
        describe(@"Cost Center", ^{
        __block NSDictionary *json;
        __block HYBCostCenter *costCenter;
        beforeAll(^{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"costCentersSampleResponse" ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];

            json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary *params = [[json objectForKey:@"costCenters"] firstObject];
            costCenter = [MTLJSONAdapter modelOfClass:[HYBCostCenter class] fromJSONDictionary:params error:nil];
            expect(costCenter).to.beTruthy();
        });
        it(@"should create new costCenter from json", ^{
            expect(costCenter.name).to.beTruthy();
            expect(costCenter.name).to.equal(@"Custom Retail");
            expect(costCenter.code).to.beTruthy();
            expect(costCenter.code).to.equal(@"Custom Retail");
        });
        it(@"should retrieve the delivery addresses on the cost center", ^{
            expect(costCenter.addresses).to.beTruthy();
            HYBAddress *address = costCenter.addresses.firstObject;
            expect(address).to.beTruthy();
            expect(address.email).to.beTruthy();
            expect(address.formattedAddress).to.beTruthy();
            expect(address.countryIso).to.beTruthy();
            expect(address.countryName).to.beTruthy();
        });
        it(@"should save the cost center to cache and retrieve it.", ^{
            NSUserDefaults *cache = [[NSUserDefaults alloc] init];
            [cache rm_setCustomObject:@[costCenter] forKey:CURRENT_COST_CENTERS_KEY];

            NSArray *centers = [cache rm_customObjectForKey:CURRENT_COST_CENTERS_KEY];
            HYBCostCenter *center = centers.firstObject;
            expect(center.name).to.beTruthy();
        });
    });
SpecEnd
