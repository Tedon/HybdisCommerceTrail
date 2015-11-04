//
// HYBMainMenuController.h
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

#import <UIKit/UIKit.h>
#import "HYBSideDrawer.h"
#import "HYBViewController.h"

@protocol HYBBackEndFacade;
@class HYBCatalogController;
@class HYBDashboardController;
@class HYBLoginViewController;
@class HYBMainMenuView;

@interface HYBMainMenuController : HYBViewController <HYBSideDrawer>

@property(nonatomic) HYBMainMenuView *mainView;
@end
