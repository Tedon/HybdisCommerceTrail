//
// UIView+HYBBase.h
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

#import <Foundation/Foundation.h>


/**
* Class representing the base functionality for all view used in this architecture.
* @see layoutSubviewsHorizontally and @see layoutSubviewsVertically are specifically important.
* Execute this methods to apply the constraints that are defined the the classy config file stylesheet.cas .
* You need to call the layout methods on any view that contains the subviews you want to layout using classy and constraints.
*
* For more information on class see the framework homepage http://classy.as/
* For integration of classy and constraints see the framework homepage https://github.com/olegam/ClassyLiveLayout
*
* As example please take a look at the class implementation HYBLoginView.m
*/
@interface UIView (HYBBase)

- (instancetype)initScrollViewWithStyleClassId:(NSString *)styleClass;

- (instancetype)initWithStyleClassId:(NSString *)styleClass;

- (void)replaceStyle:(NSString *)styleToReplace withStyle:(NSString *)replaceWithStyle;

- (void)layoutSubviewsVertically;

- (void)layoutSubviewsHorizontally;

- (void)removeAllSubViews;
@end