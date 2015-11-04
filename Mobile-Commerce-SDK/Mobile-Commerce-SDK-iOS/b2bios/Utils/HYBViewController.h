//
// HYBViewController.h
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
#import "HYBBackEndFacade.h"
#import "UIView+HYBFindFirstResponder.h"

#import <MMDrawerController/MMDrawerController.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+HYBBaseController.h"

@class MMDrawerController;

/**
* Base class for all controllers to add centralized utility methods in one super class.
* All controllers in the app are extending from it.
*/
@interface HYBViewController : UIViewController

@property(nonatomic, readonly) id <HYBBackEndFacade> b2bService;

/**
 *  Constructor to create the controller, all needed methods will be performed in the constructor, so after the init the object is in the working state.
 *
 *  @param b2bService service representing the back end, it is expected that the implementation of the back end facade will be passed in.
 *
 *  @return the ready initialized controller
 */
- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService;

@end
