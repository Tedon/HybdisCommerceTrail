//
// HYBAddress.h
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
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

/**
* The class representing an address. This can be a user or a company address.
*/

@interface HYBAddress : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy) NSString *firstName;
@property(nonatomic, copy) NSString *lastName;
@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *line1;
@property(nonatomic, copy) NSString *postalCode;
@property(nonatomic, copy) NSString *shippingAddress;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *email;
@property(nonatomic, copy) NSString *town;
@property(nonatomic, copy) NSString *formattedAddress;
@property(nonatomic, copy) NSString *countryIso;
@property(nonatomic, copy) NSString *countryName;

/**
 *  return formatted address, adding break lines
 *
 *  @return nsstring formattedAddress
 */
- (id)formattedAddressBreakLines;

@end