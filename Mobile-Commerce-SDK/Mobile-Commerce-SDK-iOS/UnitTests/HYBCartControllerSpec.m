//
// HYBCartControllerSpec.m
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
#import <OCMock/OCMStubRecorder.h>
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

SpecBegin(HYBCartController)
        describe(@"HYBCartController", ^{

            __block NSDictionary *json;
            __block HYBCart *cart;
            __block NSUserDefaults *storageService;
            __block HYBCartController *controller;

            beforeAll(^{
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"presentCartSampleResponse" ofType:@"json"];
                NSData *data = [NSData dataWithContentsOfFile:filePath];

                json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                cart = [[HYBCart alloc] initWithParams:json baseStoreUrl:@"http://random.com"];
                expect(cart).to.beTruthy();

                storageService = [[NSUserDefaults alloc] init];
                [storageService rm_setCustomObject:cart forKey:CURRENT_CART_KEY];
            });
            beforeEach(^{
                id mock = [OCMockObject mockForClass:[HYB2BService class]];
                [[[mock stub] andReturn:cart] currentCartFromCache];

                UIImage *imageDummy = [UIImage imageNamed:HYB2BImageDummy];

                void (^loadImagesBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
                    DDLogDebug(@"Calling stubbed block for loadImage");
                    void(^passedBlock)(NSArray *, NSError *);
                    [invocation getArgument:&passedBlock atIndex:3];

                    passedBlock(imageDummy, nil);
                };

                [[[mock stub] andDo:loadImagesBlock] loadImageByUrl:[OCMArg any] block:[OCMArg any]];

                void (^retrieveCartBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
                    DDLogDebug(@"Calling stubbed block for retrieving the cart");
                    void(^passedBlock)(NSArray *, NSError *);
                    [invocation getArgument:&passedBlock atIndex:2];

                    passedBlock(cart, nil);
                };

                [[[mock stub] andDo:retrieveCartBlock] retrieveCurrentCartAndExecute:[OCMArg any]];

                controller = [[HYBCartController alloc] initWithBackEndService:mock];
                expect(controller).to.beTruthy();
            });
            it(@"should load a cart and render it in the view", ^{
                [controller loadView];
                [controller viewDidLoad];
                HYBCartView *view = (HYBCartView*)controller.view;
                expect(view).to.beTruthy();

                expect(view.cartTotalNumber).to.beTruthy();
                expect(view.cartTotalNumber.text).to.equal(cart.totalPriceFormatted);
            });
            afterAll(^{
                [storageService removeObjectForKey:CURRENT_CART_KEY];
            });
        });
SpecEnd
