//
// HYBCategoriesControllerSpec.m
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

#import "HYBCatalogMenuController.h"
#import "HYB2BService.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "HYBBackEndServiceStub.h"

SpecBegin(HYBCategoriesController)
  describe(@"HYBCategoriesController", ^{
      __block HYBCatalogMenuController *controller;
      __block HYBBackEndServiceStub *backEndStub;

      beforeAll(^{
          [DDLog addLogger:[DDASLLogger sharedInstance]];
          [DDLog addLogger:[DDTTYLogger sharedInstance]];

          backEndStub = [[HYBBackEndServiceStub alloc] initWithDefaults];
      });

      it(@"should init and load all the categories inside", ^{
          controller = [[HYBCatalogMenuController alloc] initWithBackEndService:backEndStub];
      });
      it(@"should load the view", ^{
          controller = [[HYBCatalogMenuController alloc] initWithBackEndService:backEndStub];
          [controller loadView];
      });
  });
SpecEnd
