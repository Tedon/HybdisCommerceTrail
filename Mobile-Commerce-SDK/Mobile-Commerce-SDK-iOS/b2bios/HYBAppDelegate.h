//
// HYBAppDelegate.h
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

@class HYB2BService;
@protocol HYBBackEndFacade;

@interface HYBAppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) UINavigationController *mainNavigationController;
@property(nonatomic, readonly) id <HYBBackEndFacade> backEndService;
@property(nonatomic) BOOL isGridView;

@end
