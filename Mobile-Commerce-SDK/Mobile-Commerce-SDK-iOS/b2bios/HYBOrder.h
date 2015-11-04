//
// HYBOrder.h
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
#import "HYBCart.h"
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class HYBDeliveryMode;
@class HYBAddress;

/**
* The class representing an order. Order go through different states and are usually created at the checkout out
* of a present cart.
*/
@interface HYBOrder : MTLModel <MTLJSONSerializing>

@property (strong) NSString *code;
@property (strong) NSString *status;
@property (strong) NSString *total;
@property (strong) HYBCart *cart;
@property (strong) HYBAddress *deliveryAddress;
@property (strong) HYBDeliveryMode *deliveryMode;

@end