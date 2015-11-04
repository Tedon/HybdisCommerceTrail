//
// HYBConstants.h
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
#import "DDLog.h"

/**
* Class to save all static constans that are used more than by one single class definition.
*/

#ifdef DEBUG
    static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
    static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define defaultAnimationDuration 0.3

extern NSString *const SIMPLE_CART_ITEM_CELL_ID;
extern NSString *const HYBOCCErrorDomain;
