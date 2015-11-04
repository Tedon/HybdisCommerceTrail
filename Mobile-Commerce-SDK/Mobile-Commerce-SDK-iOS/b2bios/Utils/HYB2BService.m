//
// HYB2BService.m
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

#import "HYB2BService.h"
#import "NSError+HYErrorUtils.h"
#import "HYBCategory.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "HYBCart.h"
#import "NSUserDefaults+RMSaveCustomObject.h"
#import "HYBCostCenter.h"
#import "HYBDeliveryMode.h"
#import "HYBOrder.h"

NSString *const NOTIFICATION_CART_UPDATED = @"NOTIFICATION_CART_UPDATED";

@implementation HYB2BService {
    MKNetworkEngine *_restEngine;
    NSUserDefaults *_userDefaults;
}

@synthesize pageOffset, pageSize;

- (int)cacheMemoryCost {
    return 0;
}

- (id)initWithDefaults {
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    pageOffset = 0;
    pageSize = 20;
    
    return self;
}

- (MKNetworkEngine *)createRestEngineWithToken:(NSString *)token host:(NSString *)host port:(NSNumber *)port {
    
    if (host == nil || port == nil) {
        NSString *msg = @"proper attributes are not given, please provide this parameters in the params hash.";
        @throw([NSException exceptionWithName:@"InitException" reason:msg userInfo:nil]);
    }
    
    DDLogVerbose(@"Creating rest engine.");
    
    NSDictionary *headers = @{@"Authorization" : token};
    
    DDLogVerbose(@"Creating engine with token %@", token);
    MKNetworkEngine *result = nil;
    if ((result = [[MKNetworkEngine alloc] initWithHostName:host customHeaderFields:headers])) {
        result.portNumber = [port intValue];
        if ([self isUsingCache]) {
            [result useCache];
        }
    }
    DDLogVerbose(@"Rest Engine was created.");
    return result;
}

#pragma mark - Pagination Utilities

- (void)resetPagination {
    pageOffset = 0;
}

- (void)nextPage {
    pageOffset++;
}

#pragma mark - Products Functionality

- (void)findProductsWithBlock:(void (^)(NSArray *, NSError *))toExecute {
    NSDictionary *params = @{@"pageSize" : [NSString stringWithFormat:@"%d", pageSize],
                             @"currentPage" : [NSString stringWithFormat:@"%d", pageOffset]};
    
    NSString *url = [self productsUrlForStore:[self currentStoreId]];
    [self doGETWithUrl:url params:params disableCache:NO block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            toExecute(nil, error);
        } else {
            NSMutableArray *productsContainer = [self productsFromJSONResponse:JSON jsonTreePath:@"products"];
            toExecute([NSArray arrayWithArray:productsContainer], nil);
        }
    }];
}

- (void)findProductsBySearchQuery:(NSString *)query andExecute:(void (^)(NSArray *foundProducts, NSString *spellingSuggestion, NSError *error))toExecute {
    if (![query hyb_isNotBlank]) {
        query = @"";
    }
    
    NSDictionary *params = @{@"pageSize" : [NSString stringWithFormat:@"%d", pageSize],
                             @"currentPage" : [NSString stringWithFormat:@"%d", pageOffset],
                             @"query" : query};
    
    [self findProductsByParams:params andExecute:toExecute];
}

- (void)findProductsByParams:(NSDictionary *)params andExecute:(void (^)(NSArray *, NSString *spellingSuggestion, NSError *error))toExecute {
    NSString *url = [self productsUrlForStore:[self currentStoreId]];
    [self doGETWithUrl:url params:params disableCache:NO block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            toExecute(nil, nil, error);
        } else {
            NSMutableArray *productsContainer = [self productsFromJSONResponse:JSON jsonTreePath:@"products"];
            
            NSDictionary *jsonReponse = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)JSON];
            NSString *spellingSuggestion = [jsonReponse valueForKeyPath:@"spellingSuggestion.suggestion"];
            NSNumber *totalResults = [jsonReponse valueForKeyPath:@"pagination.totalResults"];
            self.totalSearchResults = totalResults.intValue;
            self.currentPage = [[jsonReponse valueForKeyPath:@"pagination.currentPage"] intValue];
            self.pageSize = [[jsonReponse valueForKeyPath:@"pagination.pageSize"] intValue];
            toExecute([NSArray arrayWithArray:productsContainer], spellingSuggestion, nil);
        }
    }];
}

- (void)findProductsByCategoryId:(NSString *)categoryId withBlock:(void (^)(NSArray *foundCategories, NSError *error))block {
    NSAssert(categoryId != nil, @"Category must be present");
    
    NSDictionary *params = @{@"pageSize" : [NSString stringWithFormat:@"%d", pageSize], @"currentPage" : [NSString stringWithFormat:@"%d", pageOffset]};
    
    NSString *url = [self productsUrlForStore:[self currentStoreId] categoryId:categoryId];
    
    [self doGETWithUrl:url
                params:params
          disableCache:NO
                 block:^(MKNetworkOperation *JSON, NSError *error) {
                     
                     if (error) {
                         block(nil, error);
                     } else {
                         NSMutableArray *productsContainer = [self productsFromJSONResponse:JSON jsonTreePath:@"products"];
                         
                         block([NSArray arrayWithArray:productsContainer], nil);
                     }
                     
                 }];
}

- (NSMutableArray *)productsFromJSONResponse:(MKNetworkOperation *)JSON jsonTreePath:(NSString *)jsonPath {
    NSArray *productsJSON = [JSON valueForKeyPath:jsonPath];
    
    NSMutableArray *productsContainer = [NSMutableArray arrayWithCapacity:[productsJSON count]];
    
    for (NSDictionary *prodAttributes in productsJSON) {
        NSMutableDictionary *allAttributes = [[NSMutableDictionary alloc] initWithDictionary:prodAttributes];
        NSString *baseUrl = [self baseStoreUrl];
        [productsContainer addObject:[[HYBProduct alloc] initWithParams:allAttributes baseStoreUrl:baseUrl]];
    }
    
    DDLogVerbose(@"Product data retrieved, with %lu new entries", (unsigned long) productsContainer.count);
    return productsContainer;
}

- (void)findProductById:(NSString *)productId withBlock:(void (^)(HYBProduct *, NSError *))block {
    NSDictionary *params = @{@"fields" : @"FULL"};
    NSString *url = [self productDetailsURLForProduct:productId insideStore:[self currentStoreId]];
    
    [self doGETWithUrl:url params:params disableCache:NO block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            block(nil, error);
        } else {
            NSMutableDictionary *allAttribs = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
            block([[HYBProduct alloc] initWithParams:allAttribs baseStoreUrl:[self baseStoreUrl]], nil);
        }
    }];
}


#pragma mark - Current properties and state variables

- (NSString *)currentStoreId {
    return [self.userDefaults objectForKey:@"current_store"];
}

- (NSString *)currentCatalogId {
    return [self.userDefaults objectForKey:@"current_catalog"];
}

- (NSString *)currentCatalogVersion {
    return [self.userDefaults objectForKey:@"current_catalog_version"];
}

- (NSString *)rootCategoryId {
    return @"1";
}

- (NSString *)currentUserId {
    return [_userDefaults objectForKey:LAST_AUTHENTICATED_USER_KEY];
}

- (NSString *)currentUserEmail {
    return [_userDefaults objectForKey:LAST_AUTHENTICATED_USER_KEY];
}

- (NSUserDefaults *)userStorage {
    return _userDefaults;
}

- (BOOL)isUsingCache {
    return [((NSNumber *) [_userDefaults objectForKey:USE_CACHE_ATTRIBUTE_KEY]) boolValue];
}

- (NSString *)restUrlPrefix {
    return [_userDefaults objectForKey:REST_URL_ATTRIBUTE_KEY];
}

#pragma mark - Authentication and Authorization

- (void)authenticateUser:(NSString *const)user password:(NSString *)pass block:(void (^)(NSString *, NSError *))block {
    
    [self retrieveToken:user password:pass block:^(NSString *token, NSError *error) {
        if (error) {
            DDLogError(@"Problems during the auth token retrieval, reason: %@", [error localizedDescription]);
            block(NSLocalizedString(@"login_failed_wrong_credentials", nil), error);
        } else {
            NSString *authToken = token;
            DDLogDebug(@"Token retrieved.");
            
            DDLogDebug(@"Auth success");
            
            [self fetchCustomerGroupsFor:user token:authToken block:^(NSArray *customerGroups, NSError *error) {

                NSAssert([customerGroups hyb_isNotBlank], @"Customer groups must be present or at least not nil.");

                if (error) {
                    DDLogError(@"Problems during the retrieval of user roles: %@", [error localizedDescription]);
                    block(NSLocalizedString(@"login_error_retrieving_the_user_roles", @""), error);
                    
                } else if ([customerGroups containsObject:BUYERGROUP]) {
                    [_userDefaults setObject:user forKey:LAST_AUTHENTICATED_USER_KEY];
                    [_userDefaults setObject:user forKey:PREVIOUSLY_AUTHENTICATED_USER_KEY];
                    [_userDefaults synchronize];
                    
                    [self insertAuthTokenToEngine:authToken];
                    
                    block(NSLocalizedString(@"login_success", nil), nil);
                } else {
                    NSString *msg = NSLocalizedString(@"login_wrong_user_role", nil);
                    block(msg, [self createDefaultErrorWithMessage:msg failureReason:nil]);
                }
            }];
        }
    }];
}


- (void)fetchCustomerGroupsFor:(NSString *)user token:(NSString *)token block:(void (^)(NSArray *, NSError *))block {
    NSArray *userGroups;
    DDLogDebug(@"Start role recognition for user: %@", user);
    //TODO add proper user group recognition, doing a separate call to details
    userGroups = @[@"customergroup", BUYERGROUP];
    DDLogDebug(@"Authentication successfull, user groups are: %@", userGroups);
    block(userGroups, nil);
}

- (void)retrieveToken:(NSString *)user password:(NSString *)pass block:(void (^)(NSString *, NSError *))block {
    NSString *url = @"rest/oauth/token";
    
    NSDictionary *presentTokenDetails = [_userDefaults dictionaryForKey:user];
    
    if ([presentTokenDetails hyb_isNotBlank]) {
        [self refreshTokenForUser:user presentTokenDetails:presentTokenDetails block:block];
    } else {
        __block NSString *token = nil;
        DDLogVerbose(@"Retrieving a first time token for the user %@ .", user);
        NSDictionary *params = @{@"username" : user, @"password" : pass, @"grant_type" : @"password"};
        [self doGETWithUrl:url params:params disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
            if (error) {
                DDLogError(@"Error during retrieval of the token: %@", error);
                block(NSLocalizedString(@"login_failed_checkcredentials_or_user_rights", nil), error);
            } else {
                NSMutableDictionary *resposeValues = [self saveToStorageByUserId:user JSON:JSON];
                token = [resposeValues objectForKey:HYB2B_ACESS_TOKEN_KEY];
                block(token, nil);
            }
        }];
    }
}

- (void)refreshTokenForUser:(NSString *)user presentTokenDetails:(NSDictionary *)presentTokenDetails block:(void (^)(NSString *, NSError *))block {
    NSString *url = @"rest/oauth/token";
    DDLogVerbose(@"Token for the user %@ found.", user);
    NSString *presentToken = [presentTokenDetails objectForKey:HYB2B_ACESS_TOKEN_KEY];
    __block NSString *token = nil;
    if ([self isExpiredToken:presentTokenDetails]) {
        DDLogVerbose(@"Token for the user %@ is expired and will be refreshed.", user);
        NSString *refreshToken = [presentTokenDetails objectForKey:HYB2B_REFRESH_TOKEN_KEY];
        
        NSDictionary *refreshTokenParams = @{@"grant_type" : @"refresh_token", @"client_id" : @"mobile_android",
                                             @"client_secret" : @"secret", @"refresh_token" : refreshToken};
        
        [self doGETWithUrl:url params:refreshTokenParams disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
            if (error) {
                DDLogError(@"Error during refreshing the token, this is either a web service "
                           "issue or a connectivity problem.: %@", error);
                block(NSLocalizedString(@"login_failed_checkcredentials_or_user_rights", nil), error);
            } else {
                NSMutableDictionary *resposeValues = [self saveToStorageByUserId:user JSON:JSON];
                token = [resposeValues objectForKey:HYB2B_ACESS_TOKEN_KEY];
                block(token, nil);
            }
        }];
        
    } else {
        DDLogVerbose(@"Token for the user %@ is STILL VALID and will be reused.", user);
        token = presentToken;
        block(token, nil);
    }
}

- (NSMutableDictionary *)saveToStorageByUserId:(NSString *)userId JSON:(MKNetworkOperation *)JSON {
    
    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
    NSMutableDictionary *resposeValues = [[NSMutableDictionary alloc] initWithDictionary:tempDictionary];
    
    NSNumber *millisecondsToExpire = [resposeValues objectForKey:HYB2B_EXPIRE_VALUE_KEY];
    double secondsToExpire = millisecondsToExpire.doubleValue / 1000;
    NSDate *expirationTime = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsToExpire];
    resposeValues[HYB2B_EXPIRATION_TIME_KEY] = expirationTime;
    
    [_userDefaults setObject:resposeValues forKey:userId];
    [_userDefaults synchronize];
    
    return resposeValues;
}

- (BOOL)isExpiredToken:(NSDictionary *)tokenData {
    NSDate *expirationTime = [tokenData objectForKey:HYB2B_EXPIRATION_TIME_KEY];
    NSTimeInterval remainingMillisecondsToExpiration = [expirationTime timeIntervalSinceNow];
    BOOL isSomeRemainingMills = remainingMillisecondsToExpiration > 1;
    return !isSomeRemainingMills;
}

- (void)logoutCurrentUser {
    
    _restEngine = nil;
    
    NSString *currentUserId = [_userDefaults objectForKey:LAST_AUTHENTICATED_USER_KEY];
    
    if (currentUserId) {
        [_userDefaults removeObjectForKey:currentUserId];
        [_userDefaults removeObjectForKey:LAST_AUTHENTICATED_USER_KEY];
        [_userDefaults removeObjectForKey:CURRENT_CART_KEY];
        [_userDefaults removeObjectForKey:CURRENT_COST_CENTERS_KEY];
    }
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] bk_each:^(NSHTTPCookie *cookie) {
        DDLogVerbose(@"Deleting present cookie %@", [cookie description]);
        [storage deleteCookie:cookie];
    }];
    
    [_userDefaults synchronize];
}

#pragma mark - Loading Images

- (void)loadImageByUrl:(NSString *)url block:(void (^)(UIImage *, NSError *))block {
    DDLogVerbose(@"Loading full image for url %@", url);
    if ([url hyb_isNotBlank]) {
        NSURL *fullURL = [NSURL URLWithString:url];
        DDLogVerbose(@"Url is valid starting download of %@", fullURL);
        [self.restEngine imageAtURL:fullURL completionHandler:^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) {
            block(fetchedImage, nil);
        }              errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            if ([error hyb_isNotBlank] && [error isConnectionOfflineError]) {
                DDLogWarn(@"image retrieval failed, since device is disconnected, images will be taken from the cache: %@",
                          [error localizedDescription]);
            } else {
                DDLogWarn(@"image retrieval failed, a dummy will be created, reason: %@", [error localizedDescription]);
                UIImage *dummy = [UIImage imageNamed:HYB2BImageDummy];
                block(dummy, error);
            }
        }];
    } else {
        NSString *msg = @"image retrieval failed, given url is blank, a dummy will be created.";
        UIImage *generatedImage = [UIImage imageNamed:HYB2BImageDummy];
        block(generatedImage, [self createDefaultErrorWithMessage:msg failureReason:nil]);
    }
}

- (void)loadImagesForProduct:(HYBProduct *)product block:(void (^)(NSMutableArray *images, NSError *error))block {

    NSAssert([product hyb_isNotBlank], @"Product must be not nil");

    NSMutableArray *galleryImages = [product galleryImagesData];
    DDLogDebug(@"Loading %lu gallery images for product %@", (unsigned long) galleryImages.count, product.code);
    NSMutableArray *images = [[NSMutableArray alloc] init];
    [galleryImages bk_each:^(id obj) {
        NSDictionary *data = (NSDictionary *) obj;
        NSString *fullImageUrl = [product createFullUrlFromPartUrl:[data objectForKey:@"url"]];
        [self loadImageByUrl:fullImageUrl block:^(UIImage *image, NSError *error) {
            DDLogDebug(@"Adding loaded image %@", image);
            [images addObject:image];
            if ([images count] == [galleryImages count]) {
                DDLogDebug(@"Image download ready with %lu results.", (unsigned long) [images count]);
                block(images, nil);
            }
        }];
    }];
}

#pragma mark - Categories Functionality

- (void)findCategoriesWithBlock:(void (^)(NSArray *, NSError *))block {
    
    NSString *url = [self categoriesUrlWithStore:[self currentStoreId]
                                       catalogId:[self currentCatalogId]
                                catalogVersionId:[self currentCatalogVersion]
                                  rootCategoryId:[self rootCategoryId]];
    
    [self doGETWithUrl:url params:nil disableCache:NO block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            block(nil, error);
        } else {

            NSArray *categoriesJSON = (NSArray *) JSON;

            NSAssert([categoriesJSON hyb_isNotBlank], @"categories json must be valid after rest service response.");

            NSMutableArray *categoriesContainer = [NSMutableArray arrayWithCapacity:[categoriesJSON count]];
            HYBCategory *categoryTree = [[HYBCategory alloc] initWithAttributesAsTree:categoriesJSON];
            [categoriesContainer addObject:categoryTree];
            
            DDLogDebug(@"Categories data retrieved, with %lu new entries", (unsigned long) categoriesContainer.count);
            
            block([NSArray arrayWithArray:categoriesContainer], nil);
        }
    }];
}

#pragma mark - Cart Functionality

- (void)addProductToCurrentCart:(NSString *)productCode amount:(NSNumber *)amount block:(void (^)(HYBCart *cart, NSString *msg))toExecute {
    
    NSAssert([productCode hyb_isNotBlank], @"Product code is empty");
    NSAssert(amount.intValue > 0, @"Given amount of products to add is invalid");
    
    NSString *userId = [self currentUserId];
    
    HYBCart *cart = [self currentCartFromCache];
    
    NSString *url = [self addToCartUrlForCurrentUser:cart.code];
    NSDictionary *params = @{@"product" : productCode, @"quantity" : [NSString stringWithFormat:@"%d", amount.intValue]};
    
    [self doPOSTWithUrl:url
                 params:params
           disableCache:YES
                  block:^(MKNetworkOperation *JSON, NSError *error) {
                      
                      if (error) {
                          
                          NSString *localizedMsg = NSLocalizedString(@"Product %@ was not added to the cart. Reason: '%@'",
                                                                     @"Product %@ was not added to the cart. Reason: %@");
                          DDLogError(@"Problems during adding items to the cart %@ for user %@ reason is %@", cart.code, userId, error.localizedDescription);
                          NSString *msg = [NSString stringWithFormat:localizedMsg, productCode, [error localizedDescription]];
                          
                          toExecute(nil, msg);
                      }
                      else {
                          
                          NSString *localizedMsg = [self localizedMsgFromResponse:JSON];
                          [self retrieveCartByUserIdFromCurrentCartsCreateIfNothingPresent:userId
                                                                                andExecute:^(HYBCart *cart, NSError *error) {
                                                                                    toExecute(cart, localizedMsg);
                                                                                }];
                      }
                      
                  }];
    
}


- (void)updateProductOnCurrentCartAmount:(NSString *)entryNumber mount:(NSNumber *)amountToAdd andExecute:(void (^)(HYBCart *, NSString *))toExecute {
    HYBCart *cart = [self currentCartFromCache];
    NSString *url = [self updateCartUrlForCurrentUser:cart.code entryNumber:entryNumber];
    [self updateCartWithUrl:url updatedParams:@{@"quantity" : amountToAdd.stringValue} andExecute:^(HYBCart *cart, NSError *error) {
        if (error) {
            toExecute(nil, error.description);
        } else {
            [self retrieveCurrentCartAndExecute:^(HYBCart *refreshedCart, NSError *error) {
                toExecute(refreshedCart, nil);
            }];
        }
    }];
}


- (NSString *)localizedMsgFromResponse:(MKNetworkOperation *)JSON {
    //                    LowStock
    //                    "quantity": 300,
    //                    "quantityAdded": 295,
    //                    "statusCode": "lowStock",
    //                    "statusMessage": "A lower quantity of this product has been added to your cart due to insufficient stock."
    // TODO report to WS implementation inconsistancy in status message for success case.
    //                    Success
    //                    "quantity": 5,
    //                    "quantityAdded": 5,
    //                    "statusCode": "success"
    // TODO report WS implementation missing period after product name and missing amount added.
    //                    NoStock
    //                    "quantity": 500,
    //                    "quantityAdded": 0,
    //                    "statusCode": "noStock",
    //                    "statusMessage": "Sorry, there is insufficient stock for your basket. W6VA4 6mm Screwdriver"
    
    NSDictionary *responseValues = [[NSDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
    
    NSNumber *quantityAdded = [responseValues objectForKey:@"quantityAdded"];
    NSString *statusMsg = [responseValues objectForKey:@"statusMessage"];
    NSString *statusCode = [responseValues objectForKey:@"statusCode"];
    
    NSString *localizedMsg;
    if ([statusCode isEqualToString:@"success"]) {
        if ([statusMsg hyb_isNotBlank]) {
            localizedMsg = statusMsg;
        } else {
            localizedMsg = [NSString stringWithFormat:@"%d item(s) added", [quantityAdded intValue]];
        }
    } else {
        if (statusMsg) {
            localizedMsg = [NSString stringWithFormat:@"%@ %d item(s) added", statusMsg, [quantityAdded intValue]];
        } else {
            DDLogError(@"Problems while retrieving the message for the add to cart action: The status message is missing.");
            localizedMsg = [NSString stringWithFormat:@"Problems while adding products to cart. Error was reported."];
        }
    }
    return localizedMsg;
}

// please leave this method, will be used once currentCart web service is properly implemented
//- (void)retrieveCartByUserId:(NSString *)userId withBlock:(void (^)(HYBCart *, NSError *))executeWith {
//    NSString *url = [self currenctCartURLForUser:userId insideStore:[self currentStoreId]];
//    [self doGETWithUrl:url params:@{@"fields" : @"FULL"} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
//        if (error) {
//            DDLogInfo(@"User %@ seems to have no cart yet, a new cart will be created.", userId);
//            [self createCartForUser:userId withBlock:^(HYBCart *cart, NSError *error) {
//                if (error) {
//                    DDLogError(@"Problems while the creation of a new cart for the user %@, reason is %@", userId, error.description);
//                    executeWith(nil, error);
//                } else {
//                    [userDefaults rm_setCustomObject:cart forKey:CURRENT_CART_KEY];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CART_UPDATED object:self];
//                    executeWith(cart, nil);
//                }
//            }];
//        } else {
//            NSDictionary *JSON = [[NSDictionary alloc] initWithDictionary:JSON];
//            HYBCart *cart = [[HYBCart alloc] initWithParams:JSON baseStoreUrl:[self baseStoreUrl]];
//            if ([cart hyb_isNotBlank]) {
//                [userDefaults rm_setCustomObject:cart forKey:CURRENT_CART_KEY];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CART_UPDATED object:self];
//                executeWith(cart, nil);
//            } else {
//                DDLogError(@"Problems retrieving cart for user %@", userId);
//                executeWith(nil, [[NSError alloc] initWithCoder:[NSCoder alloc]]);
//            }
//        }
//    }];
//}

- (void)retrieveCartByUserIdFromCurrentCartsCreateIfNothingPresent:(NSString *)userId andExecute:(void (^)(HYBCart *, NSError *))toExecute {
    
    [self retrieveAllCartsForUser:userId withBlock:^(NSArray *foundCarts, NSError *error) {
        if (error) {
            toExecute(nil, error);
        } else {
            if ([foundCarts hyb_isNotBlank]) {
                HYBCart *firstCart = foundCarts.firstObject;
                [self saveCartInCacheNotifyObservers:firstCart];
                toExecute(firstCart, nil);
            } else {
                DDLogInfo(@"User %@ seems to have no cart yet, a new cart will be created.", userId);
                [self createCartForUser:userId andExecute:^(HYBCart *cart, NSError *error) {
                    if (error) {
                        DDLogError(@"Problems while the creation of a new cart for the user %@, reason is %@", userId, error.description);
                        toExecute(nil, error);
                    } else {
                        [self saveCartInCacheNotifyObservers:cart];
                        toExecute(cart, nil);
                    }
                }];
            }
        }
    }];
}

- (void)saveCartInCacheNotifyObservers:(HYBCart *)firstCart {
    [_userDefaults rm_setCustomObject:firstCart forKey:CURRENT_CART_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CART_UPDATED object:self];
}

- (void)retrieveAllCartsForUser:(NSString *)userId withBlock:(void (^)(NSArray *, NSError *))executeWith {
    NSString *url = [self cartsURLForUser:userId insideStore:[self currentStoreId]];
    
    [self doGETWithUrl:url params:@{@"fields" : @"FULL"} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
        NSDictionary *values = [[NSDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
        if (error) {
            executeWith(nil, error);
        } else {
            if ([values hyb_isNotBlank] && [values objectForKey:@"carts"]) {
                NSArray *carts = [values objectForKey:@"carts"];
                
                if ([carts hyb_isNotBlank]) {
                    NSMutableArray *result = [NSMutableArray arrayWithCapacity:carts.count];
                    
                    for (NSDictionary *cartValues in carts) {
                        HYBCart *cart = [[HYBCart alloc] initWithParams:cartValues baseStoreUrl:[self baseStoreUrl]];
                        if (cart && [cart.status isEqualToString:CART_OK])
                            [result addObject:cart];
                        else {
                            DDLogError(@"Faulty cart detected for this user %@", userId);
                            
                            [self deleteCartForUser:userId
                                           byCartId:cart.code
                                        executeWith:nil];
                        }
                    }
                    executeWith([NSArray arrayWithArray:result], nil);
                } else {
                    DDLogError(@"There seem to be no carts for this user %@", userId);
                    executeWith([NSArray array], nil);
                }
            } else {
                DDLogError(@"There seem to be no carts for this user %@", userId);
                executeWith([NSArray array], nil);
            }
        }
    }];
}

- (void)retrieveCurrentCartAndExecute:(void (^)(HYBCart *, NSError *))toExecute {
    [self retrieveCartByUserIdFromCurrentCartsCreateIfNothingPresent:[self currentUserId] andExecute:^(HYBCart *cart, NSError *error) {
        toExecute(cart, error);
    }];
}

- (void)createCartForUser:(NSString *)userId andExecute:(void (^)(HYBCart *, NSError *))toExecute {
    NSString *url = [self cartsURLForUser:userId insideStore:[self currentStoreId]];
    [self doPOSTWithUrl:url params:@{} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            toExecute(nil, error);
        } else {
            NSDictionary *cartParams = [[NSDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
            HYBCart *cart = [[HYBCart alloc] initWithParams:cartParams baseStoreUrl:[self baseStoreUrl]];
            toExecute(cart, nil);
        }
    }];
}

- (void)deleteCartForUser:(NSString *)userId byCartId:(NSString *)cartId executeWith:(void (^)(NSString *, NSError *))execute {
    NSString *url = [self cartByIdURLForUser:userId insideStore:self.currentStoreId cartId:cartId];
    [self doDELETEWithUrl:url params:@{} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            execute(nil, error);
        } else {
            execute(@"Cart with code %ld was deleted.", nil);
        }
    }];
}

- (void)setPaymentType:(NSString *)paymentType onCartWithCode:(NSString *)code execute:(void (^)(HYBCart *, NSError *))toExecute {
    NSString *url = [self setPaymenTypeUrlCode:code userId:[self currentUserId] storeId:self.currentStoreId];
    [self updateCartWithUrl:url updatedParams:@{@"paymentType" : paymentType, @"fields" : @"FULL"} andExecute:^(HYBCart *cart, NSError *error) {
        toExecute(cart, error);
    }];
}

- (void)setDeliveryAddressWithCode:(NSString *)addressId onCartWithCode:(NSString *)cartCode andExecute:(void (^)(HYBCart *, NSError *))toExecute {
    NSString *url = [self setDeliveryAddressUrlCode:cartCode userId:[self currentUserId] storeId:self.currentStoreId];
    [self updateCartWithUrl:url updatedParams:@{@"addressId" : addressId, @"fields" : @"FULL"} andExecute:^(HYBCart *cart, NSError *error) {
        toExecute(cart, error);
    }];
}

- (void)setCostCenterWithCode:(NSString *)costCenterCode onCartWithCode:(NSString *)cartCode andExecute:(void (^)(HYBCart *, NSError *))toExecute {
    NSString *url = [self setCostCenterUrlForCartCode:cartCode userId:[self currentUserId] storeId:self.currentStoreId];
    [self updateCartWithUrl:url updatedParams:@{@"costCenterId" : costCenterCode, @"fields" : @"FULL"} andExecute:^(HYBCart *cart, NSError *error) {
        toExecute(cart, error);
    }];
}

- (HYBCart *)currentCartFromCache {
    return [[self userStorage] rm_customObjectForKey:CURRENT_CART_KEY];
}

- (void)costCentersForCurrentStoreAndExecute:(void (^)(NSArray *, NSError *))toExecute {
    NSString *url = [self costCentersUrlForStore:[self currentStoreId]];
    
    NSArray *currentCostCentersFromCache = [[self userDefaults] rm_customObjectForKey:CURRENT_COST_CENTERS_KEY];
    if (currentCostCentersFromCache && currentCostCentersFromCache.count > 0) {
        toExecute(currentCostCentersFromCache, nil);
    } else {
        [self doGETWithUrl:url params:@{} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
            if (error) {
                toExecute(nil, error);
            } else {
                NSArray *costCenters = [JSON valueForKeyPath:@"costCenters"];
                if ([costCenters hyb_isNotBlank]) {
                    NSMutableArray *foundCenters = [NSMutableArray arrayWithCapacity:costCenters.count];
                    [costCenters bk_each:^(NSDictionary *centerParams) {
                        HYBCostCenter *center = [MTLJSONAdapter modelOfClass:[HYBCostCenter class] fromJSONDictionary:centerParams error:nil];
                        [foundCenters addObject:center];
                    }];
                    [[self userDefaults] rm_setCustomObject:[NSArray arrayWithArray:foundCenters] forKey:CURRENT_COST_CENTERS_KEY];
                    toExecute([NSArray arrayWithArray:foundCenters], nil);
                } else {
                    toExecute([NSArray array], nil);
                }
            }
        }];
    }
}

- (void)getDeliveryModesForCart:(NSString *)cartCode andExecute:(void (^)(NSArray *, NSError *))toExecute {
    NSAssert([cartCode hyb_isNotBlank], @"Cart code was not given.");
    NSString *url = [self getDeliveryModesUrlWithCode:cartCode userId:[self currentUserId] storeId:self.currentStoreId];
    [self doGETWithUrl:url params:@{} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            toExecute(nil, error);
        } else {
            NSArray *modes = [JSON valueForKeyPath:@"deliveryModes"];
            if ([modes hyb_isNotBlank]) {
                NSMutableArray *foundDeliveryModes = [NSMutableArray arrayWithCapacity:modes.count];
                [modes bk_each:^(NSDictionary *modeParam) {
                    HYBDeliveryMode *m = [MTLJSONAdapter modelOfClass:[HYBDeliveryMode class] fromJSONDictionary:modeParam error:nil];
                    [foundDeliveryModes addObject:m];
                }];
                toExecute([NSArray arrayWithArray:foundDeliveryModes], nil);
            } else {
                toExecute([NSArray array], nil);
            }
        }
    }];
}

- (void)setDeliveryModeWithCode:(NSString *)modeCode onCartWithCode:(NSString *)cartCode andExecute:(void (^)(HYBCart *, NSError *))toExecute {
    NSString *url = [self setDeliveryModeUrlForCartCode:cartCode userId:[self currentUserId] storeId:self.currentStoreId];
    [self updateCartWithUrl:url updatedParams:@{@"deliveryModeId" : modeCode, @"fields" : @"FULL"} andExecute:^(HYBCart *cart, NSError *error) {
        toExecute(cart, error);
    }];
}

- (void)placeOrderWithCart:(HYBCart *)cart andExecute:(void (^)(HYBOrder *, NSError *))toExecute {
    NSAssert([cart hyb_isNotBlank], @"Cart code must be present");
    NSString *url = [self placeOrderURLForUser:[self currentUserId] insideStore:[self currentStoreId]];
    DDLogInfo(@"Placing the order for cart %@", cart.code);
    [self doPOSTWithUrl:url params:@{@"termsChecked" : @"true", @"cartId" : cart.code} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            toExecute(nil, error);
        } else {
            
            if (JSON) {
                DDLogInfo(@"ORDER PLACED!");
                NSDictionary *orderValues = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)JSON];
                NSString *orderCode = [orderValues objectForKey:@"code"];
                [self findOrderByCode:orderCode andExecute:^(HYBOrder *order, NSError *error) {
                    if (error) {
                        toExecute(nil, error);
                    } else {
                        toExecute(order, nil);
                    }
                }];
            } else {
                DDLogInfo(@" -+- ORDER NOT PLACED! -+- probably authentication timeout or not complete");
            }
        }
    }];
}

- (void)findOrderByCodeFromAllOrdersOrTakeFirst:(NSString *)code andExecute:(void (^)(HYBOrder *, NSError *))toExecute {
    NSString *userId = [self currentUserId];
    [self retrieveAllOrdersForUser:userId andExecute:^(NSArray *foundOrders, NSError *error) {
        if (error) {
            toExecute(nil, error);
        } else {
            if ([foundOrders hyb_isNotBlank]) {
                __block HYBOrder *foundOrder;
                [foundOrders bk_each:^(HYBOrder *order) {
                    if ([order.code isEqualToString:code]) {
                        foundOrder = order;
                    }
                }];
                if (foundOrder) {
                    toExecute(foundOrder, nil);
                } else {
                    DDLogError(@"Order was not found for code %@, the first order will be taken for now, please clarify why the cart and order do not have the same ids.", code);
                    toExecute(foundOrders.firstObject, nil);
                }
            } else {
                toExecute(nil, [self createDefaultErrorWithMessage:[NSString stringWithFormat:@"No order was found for the given code %@", code] failureReason:nil]);
            }
        }
    }];
}

- (void)findOrderByCode:(NSString *)code andExecute:(void (^)(HYBOrder *, NSError *))executeWith {
    NSAssert([code hyb_isNotBlank], @"Order code must be given.");
    
    NSString *url = [self orderByCodeForUserUrl:code userId:[self currentUserId] insideStore:[self currentStoreId]];
    
    [self doGETWithUrl:url params:@{@"fields" : @"FULL"} disableCache:NO block:^(MKNetworkOperation *JSON, NSError *error) {
        NSDictionary *values = [[NSDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
        if (error) {
            executeWith(nil, error);
        } else {
            HYBOrder *order = [MTLJSONAdapter modelOfClass:[HYBOrder class] fromJSONDictionary:values error:nil];
            executeWith(order, nil);
        }
    }];
}

- (void)retrieveAllOrdersForUser:(NSString *)userId andExecute:(void (^)(NSArray *, NSError *))executeWith {
    NSString *url = [self ordersURLForUser:userId insideStore:[self currentStoreId]];
    
    [self doGETWithUrl:url params:@{@"fields" : @"FULL"} disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
        NSDictionary *values = [[NSDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
        if (error) {
            executeWith(nil, error);
        } else {
            if ([values hyb_isNotBlank] && [values objectForKey:@"orders"]) {
                NSArray *orders = [values objectForKey:@"orders"];
                if ([orders hyb_isNotBlank]) {
                    NSMutableArray *result = [NSMutableArray arrayWithCapacity:orders.count];
                    [orders bk_each:^(NSDictionary *orderValues) {
                        HYBOrder *order = [MTLJSONAdapter modelOfClass:[HYBOrder class] fromJSONDictionary:orderValues error:nil];
                        [result addObject:order];
                    }];
                    executeWith([NSArray arrayWithArray:result], nil);
                } else {
                    DDLogError(@"There seem to be no orders for this user %@", userId);
                    executeWith([NSArray array], nil);
                }
            } else {
                DDLogError(@"There seem to be no orders for this user %@", userId);
                executeWith([NSArray array], nil);
            }
        }
    }];
}

#pragma mark - WS Utility Methods

- (void)doGETWithUrl:(NSString *)url
              params:(NSDictionary *)params
        disableCache:(BOOL)disableCache
               block:(void (^)(MKNetworkOperation *JSON, NSError *))block {
    [self callWSWithUrl:url httpMethod:@"GET" params:params disableCache:disableCache headersToAdd:nil block:block];
}

- (void)doPOSTWithUrl:(NSString *)url
               params:(NSDictionary *)params
         disableCache:(BOOL)disableCache
                block:(void (^)(MKNetworkOperation *JSON, NSError *))block {
    [self callWSWithUrl:url httpMethod:@"POST" params:params disableCache:disableCache headersToAdd:nil block:block];
}

- (void)doDELETEWithUrl:(NSString *)url
                 params:(NSDictionary *)params
           disableCache:(BOOL)disableCache
                  block:(void (^)(MKNetworkOperation *JSON, NSError *))block {
    [self callWSWithUrl:url httpMethod:@"DELETE" params:params disableCache:disableCache headersToAdd:nil block:block];
}

- (void)doPUTWithUrl:(NSString *)url
              params:(NSDictionary *)params
        disableCache:(BOOL)disableCache
             headers:(NSDictionary *)headersToAdd
               block:(void (^)(MKNetworkOperation *, NSError *))block {
    [self callWSWithUrl:url httpMethod:@"PUT" params:params disableCache:disableCache headersToAdd:headersToAdd block:block];
}

- (void)callWSWithUrl:(NSString *)url
           httpMethod:(NSString *)httpMethod
               params:(NSDictionary *)params
         disableCache:(BOOL)disableCache
         headersToAdd:(NSDictionary *)headersToAdd
                block:(void (^)(MKNetworkOperation *, NSError *))block {
    
    MKNetworkOperation *op = [self.restEngine operationWithPath:url
                                                         params:params
                                                     httpMethod:httpMethod
                                                            ssl:YES];
    
    DDLogDebug(@"%@ to URL %@ and params %@", httpMethod, url, params);

    [self processOperation:disableCache block:block op:op headers:headersToAdd];
}

- (void)processOperation:(BOOL)disableCache
                   block:(void (^)(MKNetworkOperation *, NSError *))block
                      op:(MKNetworkOperation *)op
                 headers:(NSDictionary *)headersToAdd {


    // remove this line to use a SSL certificate
    [op shouldContinueWithInvalidCertificate];


    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
                
        if ([completedOperation isCachedResponse]) {
            if (disableCache) {
                DDLogDebug(@"Disable cache is activated, response will be skipped");
            } else {
                DDLogVerbose(@"Data from cache ...");
                MKNetworkOperation *response = [completedOperation responseJSON];
                block(response, nil);
            }
        }
        else {
            DDLogVerbose(@"Data from web service ...");
            MKNetworkOperation *response = [completedOperation responseJSON];
            block(response, nil);
        }
    }
                errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                    MKNetworkOperation *response = [completedOperation responseJSON];
                    
                    NSArray *errors = [response valueForKeyPath:@"errors"];
                    if ([errors hyb_isNotBlank]) {
                        NSString *errorMsg = [errors.firstObject objectForKey:@"message"];
                        NSString *failureType = [errors.firstObject objectForKey:@"type"];
                        if(errorMsg) error = [self createDefaultErrorWithMessage:errorMsg failureReason:failureType];
                    }
                    
                    DDLogError(@"Error during request to web service: %@", [error localizedDescription]);
                    
                    if ([error.localizedFailureReason isEqualToString:@"InvalidTokenError"]) {
                        DDLogInfo(@"Invalid Token detected, we will try to refresh the token for the current user %@", [self currentUserId]);
                        NSDictionary *presentTokenDetails = [_userDefaults dictionaryForKey:[self currentUserId]];
                        if ([presentTokenDetails hyb_isNotBlank]) {
                            [self refreshTokenForUser:[self currentUserId] presentTokenDetails:presentTokenDetails block:^(NSString *refreshedToken, NSError *error) {
                                if (error) {
                                    DDLogError(@"Error still exists: %@", [error localizedDescription]);
                                    block(nil, error);
                                } else {
                                    [self insertAuthTokenToEngine:refreshedToken];
                                    DDLogInfo(@"Token was refreshed. Now it should work. We will tell the user to repeat his last action.");
                                    NSError *refreshError = [self createDefaultErrorWithMessage:@"You were automatically authenticated again, please repeat your last action." failureReason:nil];
                                    block(nil, refreshError);
                                }
                            }];
                        }
                    } else {
                        block(nil, error);
                    }
                }];
    
    [self.restEngine enqueueOperation:op forceReload:disableCache];
}

- (void)updateCartWithUrl:(NSString *)url
            updatedParams:(NSDictionary *)urlOrPUTParams
               andExecute:(void (^)(HYBCart *, NSError *))toExecute {
    
    [self doPUTWithUrl:url params:urlOrPUTParams disableCache:YES headers:nil block:^(MKNetworkOperation *JSON, NSError *error) {
        if (error) {
            toExecute(nil, error);
        } else {
            NSDictionary *params = [[NSDictionary alloc] initWithDictionary:(NSDictionary *) JSON];
            if ([params hyb_isNotBlank]) {
                HYBCart *cart = [[HYBCart alloc] initWithParams:params baseStoreUrl:[self baseStoreUrl]];
                if ([cart hyb_isNotBlank] && [cart.code hyb_isNotBlank]) {
                    toExecute(cart, nil);
                } else {
                    toExecute([self currentCartFromCache], nil);
                }
            } else {
                // response is not really giving the cart back we will retrieve the cart from the cache
                // TODO report this as a needed improvement
                toExecute([self currentCartFromCache], nil);
            }
        }
    }];
}

- (NSError *)createDefaultErrorWithMessage:(NSString *)errorMsg failureReason:(NSString *)failureReason {
    NSError *error;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    [userInfo setObject:errorMsg forKey:NSLocalizedDescriptionKey];
    if (failureReason) {
        [userInfo setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
    }
    error = [NSError errorWithDomain:HYBOCCErrorDomain code:HYB2B_ERROR_CODE_TECHNICAL userInfo:userInfo];
    
    return error;
}

#pragma mark - WS Engine Creation

- (void)insertAuthTokenToEngine:(NSString *)authToken {
    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", authToken];
    DDLogVerbose(@"Setting the new token to the authorize header.");
    NSString *host = [_userDefaults objectForKey:HOST_ATTRIBUTE_KEY];
    NSNumber *port = [_userDefaults objectForKey:PORT_ATTRIBUTE_KEY];
    _restEngine = [self createRestEngineWithToken:authorizationHeaderValue host:host port:port];
}

- (MKNetworkEngine *)restEngine {
    if (!_restEngine) {
        NSString *host = [_userDefaults objectForKey:HOST_ATTRIBUTE_KEY];
        NSNumber *port = [_userDefaults objectForKey:PORT_ATTRIBUTE_KEY];
        
        NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Basic %@", @"bW9iaWxlX2FuZHJvaWQ6c2VjcmV0"];
        
        _restEngine = [self createRestEngineWithToken:authorizationHeaderValue host:host port:port];
    }
    return _restEngine;
}


- (void)useCache {
    [self.restEngine useCache];
}

#pragma mark - URL Creation

- (NSString *)categoriesUrlWithStore:(NSString *)storeId
                           catalogId:(NSObject *)catalogId
                    catalogVersionId:(NSObject *)catalogVersionId
                      rootCategoryId:(NSObject *)rootCategoryId {
    
    // /rest/v1/apparel-uk/catalogs/apparelProductCatalog/Online/categories/categories
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/catalogs/%@/%@/categories/%@", [self restUrlPrefix],
                     storeId, catalogId, catalogVersionId, rootCategoryId];
    return url;
}

- (NSString *)productsUrlForStore:(NSString *)storeId categoryId:(NSString *)categoryId {
    // /rest/v2/powertools/categories/1800/products
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/categories/%@/products", [self restUrlPrefix], storeId, categoryId];
    return url;
}

- (NSString *)productDetailsURLForProduct:(NSString *)productId insideStore:(NSString *)catalogId {
    NSString *url = [NSString stringWithFormat:@"%@/%@/products/%@", [self restUrlPrefix], catalogId, productId];
    return url;
}

- (NSString *)cartsURLForUser:(NSString *)userId insideStore:(NSString *)storeId {
    ///rest/v2/powertools/users/mark.rivers@rustic-hw.com/carts/
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/carts", [self restUrlPrefix], storeId, userId];
    return url;
}

- (NSString *)ordersURLForUser:(NSString *)userId insideStore:(NSString *)storeId {
    ///rest/v2/powertools/users/mark.rivers@rustic-hw.com/orders/
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/orders", [self restUrlPrefix], storeId, userId];
    return url;
}

- (NSString *)currenctCartURLForUser:(NSString *)userId insideStore:(NSString *)storeId {
    ///rest/v2/powertools/users/mark.rivers@rustic-hw.com/carts/
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/carts/current", [self restUrlPrefix], storeId, userId];
    return url;
}

- (NSString *)cartByIdURLForUser:(NSString *)userId insideStore:(NSString *)storeId cartId:(NSString *)cartId {
    ///rest/v2/powertools/users/mark.rivers@rustic-hw.com/carts/
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/carts/%@", [self restUrlPrefix], storeId, userId, cartId];
    return url;
}

- (NSString *)orderByIdURLForUser:(NSString *)userId insideStore:(NSString *)storeId orderId:(NSString *)orderId {
    ///rest/v2/powertools/users/mark.rivers@rustic-hw.com/orders/
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/orders/%@", [self restUrlPrefix], storeId, userId, orderId];
    return url;
}

- (NSString *)costCentersUrlForStore:(NSString *)storeId {
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/costcenters", [self restUrlPrefix], storeId];
    return url;
}


- (NSString *)productsUrlForStore:(NSString *)storeId {
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/products/search", [self restUrlPrefix], storeId];
    return url;
}

- (NSString *)addToCartUrlForCurrentUser:(NSString *)cartId {
    // /rest/v2/powertools/users/mark.rivers@rustic-hw.com/carts/00004028/entries
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/carts/%@/entries", [self restUrlPrefix], [self currentStoreId], [self currentUserId], cartId];
    return url;
}


- (NSString *)updateCartUrlForCurrentUser:(NSString *)cartId entryNumber:(NSObject *)entryNumber {
    // rest/v2/powertools/users/mark.rivers@rustic-hw.com/carts/00004028/entries/0?qty=5
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/carts/%@/entries/%@", [self restUrlPrefix], [self currentStoreId], [self currentUserId], cartId, entryNumber];
    return url;
}

- (NSString *)setPaymenTypeUrlCode:(NSString *)code userId:(NSString *)userId storeId:(NSString *)storeId {
    NSString *cartUrl = [self cartByIdURLForUser:userId insideStore:storeId cartId:code];
    NSString *url = [NSString stringWithFormat:@"%@/paymenttype/", cartUrl];
    return url;
}

- (NSString *)setDeliveryAddressUrlCode:(NSString *)cartCode userId:(NSString *)userId storeId:(NSString *)storeId {
    NSString *cartUrl = [self cartByIdURLForUser:userId insideStore:storeId cartId:cartCode];
    NSString *url = [NSString stringWithFormat:@"%@/addresses/delivery/", cartUrl];
    return url;
}

- (NSString *)setDeliveryModeUrlForCartCode:(NSString *)cartCode userId:(NSString *)userId storeId:(NSString *)storeId {
    NSString *cartUrl = [self cartByIdURLForUser:userId insideStore:storeId cartId:cartCode];
    NSString *url = [NSString stringWithFormat:@"%@/deliverymode/", cartUrl];
    return url;
}

- (NSString *)setCostCenterUrlForCartCode:(NSString *)cartCode userId:(NSString *)userId storeId:(NSString *)storeId {
    NSString *cartUrl = [self cartByIdURLForUser:userId insideStore:storeId cartId:cartCode];
    NSString *url = [NSString stringWithFormat:@"%@/costcenter/", cartUrl];
    return url;
}

- (NSString *)getDeliveryModesUrlWithCode:(NSString *)cartCode userId:(NSString *)userId storeId:(NSString *)storeId {
    NSString *cartUrl = [self cartByIdURLForUser:userId insideStore:storeId cartId:cartCode];
    NSString *url = [NSString stringWithFormat:@"%@/deliverymodes/", cartUrl];
    return url;
}

- (NSString *)orderByCodeForUserUrl:(NSString *)orderCode userId:(NSString *)id insideStore:(NSString *)store {
    NSString *ordersUrl = [self ordersURLForUser:id insideStore:store];
    NSString *url = [NSString stringWithFormat:@"%@/%@", ordersUrl, orderCode];
    return url;
}

- (NSString *)placeOrderURLForUser:(NSString *)userId insideStore:(NSString *)storeId {
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/users/%@/orders", [self restUrlPrefix], storeId, userId];
    return url;
}

- (NSString *)baseStoreUrl {
    NSString *protocol = @"https";
    NSString *host = [_userDefaults objectForKey:HOST_ATTRIBUTE_KEY];
    NSString *port = [_userDefaults objectForKey:PORT_ATTRIBUTE_KEY];
    
    return [[NSString alloc] initWithFormat:@"%@://%@:%@", protocol, host, port];
}
@end