//
// HYBDeliveryMode.h
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
#import "MTLJSONAdapter.h"
#import "MTLModel.h"


/**
* The class representing a delivery mode. Delivery modes describe the kind of delivery that a commerce user orders.
*/
@interface HYBDeliveryMode : MTLModel <MTLJSONSerializing>

@property(nonatomic) NSString *name;
@property(nonatomic) NSString *fullDescription;
@property(nonatomic) NSString *code;
@property(nonatomic) NSString *formattedValue;

@end