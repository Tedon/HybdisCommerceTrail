//
// HYBAppDelegateSpec.m
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
#import "HYBAppDelegate.h"
#import "HYBBackEndFacade.h"

SpecBegin(HYBAppDelegate)
    describe(@"HYBAppDelegate", ^{
        __block HYBAppDelegate *delegate;

        beforeAll(^{
            delegate = [[HYBAppDelegate alloc] init];
        });
        it(@"should create app delegate", ^{
            expect(delegate).to.beTruthy();
        });
        it(@"should create the deault settings bundle", ^{
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            NSString *hostFromSettings = [settings objectForKey:HOST_ATTRIBUTE_KEY];
            hostFromSettings = [settings objectForKey:HOST_ATTRIBUTE_KEY];
            expect(hostFromSettings).to.beTruthy();
        });
    });
SpecEnd
