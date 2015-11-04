//
// HYBCart.h
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
#import "MKNetworkEngine.h"
#import "HYBProduct.h"
#import "HYBBackEndFacade.h"

@class HYBCart;

static NSString *const STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY = @"currently_shown_cat";
static NSString *const BUYERGROUP = @"buyergroup";
static NSString *const HYB2B_ACESS_TOKEN_KEY = @"access_token";
static NSString *const HYB2B_REFRESH_TOKEN_KEY = @"refresh_token";
static NSString *const HYB2B_EXPIRE_VALUE_KEY = @"expires_in";
static NSString *const HYB2B_EXPIRATION_TIME_KEY = @"issued_on";
static NSString *const HYB2BImageDummy = @"dummy.100x100.#004bb0";
static NSString *const CURRENT_CART_KEY = @"current_cart";
static NSString *const CURRENT_COST_CENTERS_KEY = @"current_cost_centers";
static const int HYB2B_ERROR_CODE_TECHNICAL = -57;

/**
* The class that implements the HYBBackEndFacade. In this case it is the specific b2b implementation.
*/
@interface HYB2BService : NSObject  <HYBBackEndFacade>

@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic) int pageOffset;
@property(nonatomic) int pageSize;
@property(nonatomic) int currentPage;
@property(nonatomic) int totalSearchResults;

- (id)initWithDefaults;

- (NSString *)currentStoreId;

- (NSString *)currentCatalogId;

- (NSString *)currentCatalogVersion;

- (NSString *)baseStoreUrl;

- (BOOL)isExpiredToken:(NSDictionary *)userTokenData;

- (void)doGETWithUrl:(NSString *)url params:(NSDictionary *)params disableCache:(BOOL)disableCache block:(void (^)(MKNetworkOperation *JSON, NSError *))block;

- (MKNetworkEngine *)restEngine;

- (NSString *)productDetailsURLForProduct:(NSString *)productId insideStore:(NSString *)catalogId;

- (void)retrieveAllCartsForUser:(NSString *)userId withBlock:(void (^)(NSArray *, NSError *))executeWith;

- (void)findOrderByCode:(NSString *)code andExecute:(void (^)(HYBOrder *, NSError *))execute;



@end