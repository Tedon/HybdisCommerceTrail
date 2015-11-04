//
// HYBProductDetailsControllerSpec.m
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

#define EXP_SHORTHAND

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMStubRecorder.h>
#import "HYBCatalogMenuController.h"
#import "OCMockObject.h"
#import "HYB2BService.h"
#import "OCMArg.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "HYBConstants.h"
#import "HYBProductDetailsController.h"
#import "HYBAppDelegate.h"

SpecBegin(HYBProductDetailsController)
describe(@"HYBProductDetailsController", ^{

     __block NSDictionary *json;
     __block HYBProductDetailsController *controller;
     __block HYBProduct *product;
     __block id mock;
     __block NSArray *imageDummies;

     beforeAll(^{
         [DDLog addLogger:[DDASLLogger sharedInstance]];
         [DDLog addLogger:[DDTTYLogger sharedInstance]];

         NSString *filePath = [[NSBundle mainBundle] pathForResource:@"productByIdSampleResponse" ofType:@"json"];
         NSData *data = [NSData dataWithContentsOfFile:filePath];
         json = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

         HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];

         product = [[HYBProduct alloc] initWithParams:json baseStoreUrl:[b2bService baseStoreUrl]];
         expect(product).to.beTruthy();

         mock = [OCMockObject mockForClass:[HYB2BService class]];

         void (^proxyBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
             DDLogDebug(@"Calling stubbed block for findProductById");
             void(^passedBlock)(HYBProduct *, NSError *);
             [invocation getArgument:&passedBlock atIndex:3];
             passedBlock(product, nil);
         };
         [[[mock stub] andDo:proxyBlock] findProductById:[OCMArg any] withBlock:[OCMArg any]];

         imageDummies = @[[UIImage imageNamed:HYB2BImageDummy],
                 [UIImage imageNamed:HYB2BImageDummy],
                 [UIImage imageNamed:HYB2BImageDummy],
                 [UIImage imageNamed:HYB2BImageDummy]];
         void (^loadImagesBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
             DDLogDebug(@"Calling stubbed block for findProductById");
             void(^passedBlock)(NSArray *, NSError *);
             [invocation getArgument:&passedBlock atIndex:3];

             passedBlock(imageDummies, nil);
         };
         [[[mock stub] andDo:loadImagesBlock] loadImagesForProduct:[OCMArg any] block:[OCMArg any]];

         controller = [[HYBProductDetailsController alloc] initWithBackEndService:mock productId:product.code];
         [controller loadView];
     });

     beforeEach(^{
         [controller viewDidLoad];
         expect(controller).to.beTruthy();
     });

     it(@"should load the product that will be shown", ^{
         expect(controller).to.beTruthy();
         expect(controller.product.code).to.equal(product.code);
     });

    it(@"should load the drop down variant boxes", ^{
        expect(controller).to.beTruthy();
    });


 });
SpecEnd
