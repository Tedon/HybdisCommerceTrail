//
// HYBCartViewSpec.m
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
#import "SHPAbstractView.h"
#import "HYBCartView.h"

SpecBegin(HYBCartViewSpec)
   describe(@"HYBCartViewSpec", ^{
       __block HYBCartView *view;

       beforeAll(^{
           [DDLog addLogger:[DDASLLogger sharedInstance]];
           [DDLog addLogger:[DDTTYLogger sharedInstance]];

           view = [[HYBCartView alloc] init];
       });

       beforeEach(^{
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
   });

SpecEnd
