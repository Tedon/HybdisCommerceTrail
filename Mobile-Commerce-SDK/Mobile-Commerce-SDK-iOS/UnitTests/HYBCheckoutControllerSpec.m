//
// HYBCheckoutControllerSpec.m
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
#import "NSUserDefaults+RMSaveCustomObject.h"

#define EXP_SHORTHAND

#import <Expecta/Expecta.h>
#import <ClassyLiveLayout/SHPAbstractView.h>
#import "HYBCategory.h"
#import "HYBCatalogMenuController.h"
#import "OCMockObject.h"
#import "HYB2BService.h"
#import "OCMArg.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "HYBConstants.h"
#import "HYBCartController.h"
#import "HYBCart.h"
#import "HYBCartView.h"
#import "HYBCartItemCellView.h"
#import "HYBCheckoutController.h"
#import "HYBAppDelegate.h"

SpecBegin(HYBCheckoutController)
        describe(@"HYBCheckoutController", ^{

            __block NSDictionary *json;
            __block HYBCart *cart;
            __block NSUserDefaults *storageService;
            __block HYBCheckoutController *controller;
            __block HYB2BService *backEndService;

            beforeAll(^{
                [DDLog addLogger:[DDASLLogger sharedInstance]];
                [DDLog addLogger:[DDTTYLogger sharedInstance]];

                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"presentCartSampleResponse" ofType:@"json"];
                NSData *data = [NSData dataWithContentsOfFile:filePath];

                json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                cart = [[HYBCart alloc] initWithParams:json baseStoreUrl:@"http://random.com"];
                expect(cart).to.beTruthy();

                storageService = [[NSUserDefaults alloc] init];
                [storageService rm_setCustomObject:cart forKey:CURRENT_CART_KEY];
            });

            beforeEach(^{
                NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
                [NSBundle bundleWithPath:bundlePath];

                backEndService = [[HYB2BService alloc] initWithDefaults];
                backEndService.userDefaults = [[NSUserDefaults alloc] init];

                controller = [[HYBCheckoutController alloc] initWithBackEndService:backEndService];
                expect(controller).to.beTruthy();
            });

            it(@"should load a cart and render it in the view", ^{

//                [backEndService authenticateUser:@"byung-soon.lee@rustic-hw.com" password:@"12341234" block:^(NSString *msg, NSError *error) {
//                    expect(msg).to.equal(NSLocalizedString(@"login_success", nil));
//                    expect(error).to.beFalsy();
//
//                    [backEndService retrieveCurrentCartAndExecute:^(HYBCart *cart, NSError *error) {
//                        [controller loadView];
//                        [controller viewDidLoad];
//                        UIView * view = controller.view;
//                        expect(view).to.beTruthy();
//                    }];
//                }];
            });

            afterAll(^{
                [storageService removeObjectForKey:CURRENT_CART_KEY];
            });
        });
SpecEnd
