//
// HYBCatalogControllerSpec.m
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
#import <OCMock/OCMStubRecorder.h>
#import "HYBCategory.h"
#import "HYBCatalogMenuController.h"
#import "OCMockObject.h"
#import "HYB2BService.h"
#import "OCMArg.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "HYBConstants.h"
#import "HYBCatalogController.h"
#import "HYBBackEndServiceStub.h"

SpecBegin(HYBCatalogController)
        describe(@"HYBCatalogController", ^{
            __block HYBCatalogController *controller;
            __block HYBBackEndServiceStub *backEndStub;

            beforeAll(^{
                [DDLog addLogger:[DDASLLogger sharedInstance]];
                [DDLog addLogger:[DDTTYLogger sharedInstance]];

                backEndStub = [[HYBBackEndServiceStub alloc] initWithDefaults];
            });

            it(@"should load the products", ^{
                controller = [[HYBCatalogController alloc] initWithBackEndService:backEndStub];
                NSArray *products = [controller products];
                expect(products).to.beTruthy();
            });
            it(@"should load the view", ^{
                controller = [[HYBCatalogController alloc] initWithBackEndService:backEndStub];
                [controller loadView];
            });
            it(@"should force the product reload", ^{
                controller = [[HYBCatalogController alloc] initWithBackEndService:backEndStub];
                [controller forceReload];
            });
        });
SpecEnd
