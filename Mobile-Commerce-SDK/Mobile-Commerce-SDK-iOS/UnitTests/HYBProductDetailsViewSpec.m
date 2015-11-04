//
// HYBProductDetailsViewSpec.m
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
#import <OCMock/OCMockObject.h>
#import <OCMock/OCMArg.h>
#import "SHPAbstractView.h"
#import "HYBProductDetailsView.h"
#import "HYBProduct.h"
#import "HYB2BService.h"
#import "HYBAppDelegate.h"
#import "HYBConstants.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "OCMStubRecorder.h"

SpecBegin(HYBProductDetailsViewSpec)
   describe(@"HYBProductDetailsViewSpec", ^{
       __block HYBProductDetailsView *view;
       __block NSDictionary *json;
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

           view = [[HYBProductDetailsView alloc] init];
           [view loadProductDetails:product];

       });

       it(@"should init the view", ^{
           expect(view).to.beTruthy();
       });

       it(@"should build up the layout", ^{
           expect(^{
               [view defineLayout];
           }).to.beTruthy;
       });

       it(@"should build the subviews", ^{
           expect(^{
               [view addSubviews];
           }).to.beTruthy;
       });

       it(@"should calculate the total price based on items and product prices", ^{
           int amount = 3;
           view.quantityInputField.text = [[NSString alloc] initWithFormat:@"%d", amount];
           [view calculateTotalPrice];
           float price = [[product price] floatValue];
           NSString *expectedPriceLabel = [[NSString alloc] initWithFormat:@"%.02f %@", amount * price, @"USD"];
           expect(view.totalItemPrice.text).to.equal(expectedPriceLabel);
       });

       it(@"should render the volume prices table", ^{
           [view showOrHideVolumePricing];
           [view showOrHideVolumePricing];
       });


       it(@"should render the variant picker", ^{
           UIPickerView *pickerView = nil;

           int numberOfDimensionsInPickerView = [view numberOfComponentsInPickerView:pickerView];
           expect(numberOfDimensionsInPickerView).to.equal(@3);

           int valuesInFirstDimension = [view pickerView:nil numberOfRowsInComponent:0];
           expect(valuesInFirstDimension).to.equal(@3);


           NSString *titleForRow = [view pickerView:pickerView titleForRow:0 forComponent:0];
           expect(titleForRow).to.equal(@"Black");

           titleForRow = [view pickerView:pickerView titleForRow:1 forComponent:0];
           expect(titleForRow).to.equal(@"Brown");

           titleForRow = [view pickerView:pickerView titleForRow:2 forComponent:0];
           expect(titleForRow).to.equal(@"Dark Brown");

           titleForRow = [view pickerView:pickerView titleForRow:0 forComponent:1];
           expect(titleForRow).to.equal(@"M");

           titleForRow = [view pickerView:pickerView titleForRow:1 forComponent:1];
           expect(titleForRow).to.equal(@"W");

           titleForRow = [view pickerView:pickerView titleForRow:0 forComponent:2];
           expect(titleForRow).to.equal(@"5");

           titleForRow = [view pickerView:pickerView titleForRow:2 forComponent:2];
           expect(titleForRow).to.equal(@"6");
       });
       it(@"should rotate the picker and adjust values", ^{
           UIPickerView *pickerView = [[UIPickerView alloc] init];

           NSString *titleForRow = [view pickerView:pickerView titleForRow:0 forComponent:0];
           expect(titleForRow).to.equal(@"Black");

           [view pickerView:pickerView didSelectRow:1 inComponent:0];

           [view pickerView:pickerView didSelectRow:1 inComponent:1];

           titleForRow = [view pickerView:pickerView titleForRow:0 forComponent:1];
           expect(titleForRow).to.equal(@"M");

           titleForRow = [view pickerView:pickerView titleForRow:12 forComponent:2];
           expect(titleForRow).to.equal(@"11");
       });
   });

SpecEnd
