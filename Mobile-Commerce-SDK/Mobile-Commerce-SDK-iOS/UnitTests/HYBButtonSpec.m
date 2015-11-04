//
// HYBButtonSpec.m
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
#import "HYBButton.h"

SpecBegin(HYB2BButtonSpec)
   describe(@"HYB2BButtonSpec", ^{

       __block HYBButton *button;

       beforeAll(^{
           [DDLog addLogger:[DDASLLogger sharedInstance]];
           [DDLog addLogger:[DDTTYLogger sharedInstance]];

           button = [[HYBButton alloc] initWithFrame:CGRectZero title:@"Test Button"];
       });

       it(@"should layout primary", ^{
           [button layoutAs:HYBButtonTypePrimary];
           expect(button).to.beTruthy();
       });

       it(@"should layout secondary", ^{
           [button layoutAs:HYBButtonTypeSecondary];
           expect(button).to.beTruthy();
       });

       it(@"should layout as drop down", ^{
           [button layoutAs:HYBButtonTypeDropdown];
           expect(button).to.beTruthy();
       });

       it(@"should layout as link", ^{
           [button layoutAs:HYBButtonTypeLink];
           expect(button).to.beTruthy();
       });

       it(@"should throw exception if unsupported layout type given", ^{
           expect(^{[button layoutAs:100];}).to.raiseAny();
       });

   });
SpecEnd
