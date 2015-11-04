//
// HYBServiceSpec.m
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

#import <Specta/Specta.h>

#define EXP_SHORTHAND

NSString *username = @"byung-soon.lee@rustic-hw.com";
NSString *password = @"12341234";
NSString *TEST_PRODUCT_CODE = @"1979039";

#import <Expecta/Expecta.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <BlocksKit/NSTimer+BlocksKit.h>
#import "HYBAppDelegate.h"
#import "HYB2BService.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "HYBCategory.h"
#import "HYBConstants.h"
#import "HYBCart.h"
#import "HYBCostCenter.h"
#import "HYBAddress.h"
#import "HYBDeliveryMode.h"
#import "HYBOrder.h"

SpecBegin(HYBService)
describe(@"Products Retrieval", ^{
    
    beforeAll(^{
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        [NSBundle bundleWithPath:bundlePath];
    });
    it(@"should init with caching", ^{
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        BOOL useCache = [b2bService isUsingCache];
        expect(useCache).to.beTruthy();
    });
    it(@"should retrieve the products", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService findProductsWithBlock:^(NSArray *products, NSError *error) {
            expect([products count] > 0).to.beTruthy();
            expect(error).to.beFalsy();
            done();
        }];
    });
    it(@"should search for the products by query and show a spelling suggestion", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService findProductsBySearchQuery:@"shoe" andExecute:^(NSArray *products, NSString *spellingSuggestion, NSError *error) {
            expect([products count] > 0).to.beTruthy();
            expect(spellingSuggestion).to.equal(@"sheet");
            expect(error).to.beFalsy();
            done();
        }];
    });
    it(@"should search for the products by query and save the pagination results", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        b2bService.pageSize = 5;
        
        [b2bService findProductsBySearchQuery:@"shoe" andExecute:^(NSArray *products, NSString *spellingSuggestion, NSError *error) {
            expect([products count]).to.equal(5);
            int totalSearchResults = b2bService.totalSearchResults;
            expect(totalSearchResults).to.equal(17);
            expect(error).to.beFalsy();
            done();
        }];
    });
    it(@"should retrieve the products in category", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService findCategoriesWithBlock:^(NSArray *foundCategories, NSError *error) {
            expect([foundCategories count] > 0).to.beTruthy();
            expect(error).to.beFalsy();
            
            HYBCategory *rootNode = [foundCategories firstObject];
            HYBCategory *childOfRoot = [[rootNode subCategories] lastObject];
            
            [b2bService findProductsByCategoryId:childOfRoot.id withBlock:^(NSArray *products, NSError *error) {
                expect([products count] > 0).to.beTruthy();
                done();
            }];
        }];
    });
    it(@"should retrieve a product by id", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService findProductsWithBlock:^(NSArray *products, NSError *error) {
            HYBProduct *prod = [products firstObject];
            [b2bService findProductById:prod.code withBlock:^(HYBProduct *foundProduct, NSError *error) {
                expect(foundProduct).to.beTruthy();
                expect(foundProduct.code).to.equal(prod.code);
                done();
            }];
        }];
    });
    it(@"should retrieve necessary product attributes", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService findProductsWithBlock:^(NSArray *products, NSError *error) {
            HYBProduct *prod = [products firstObject];
            [b2bService findProductById:prod.code withBlock:^(HYBProduct *foundProduct, NSError *error) {
                expect(foundProduct).to.beTruthy();
                expect(foundProduct.desc).to.beTruthy();
                expect(foundProduct.summary).to.beTruthy();
                expect(foundProduct.price).to.beTruthy();
                done();
            }];
        }];
    });
    it(@"should create a mock image for an empty given product url", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService loadImageByUrl:nil block:^(UIImage *image, NSError *error) {
            expect(image).to.beTruthy();
            expect(image.size.height).to.beGreaterThan(0);
            expect(error).to.beTruthy();
            done();
        }];
    });
    it(@"should load gallery product images", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService findProductsWithBlock:^(NSArray *products, NSError *error) {
            HYBProduct *prod = [products firstObject];
            [b2bService findProductById:prod.code withBlock:^(HYBProduct *foundProduct, NSError *error) {
                expect(foundProduct).to.beTruthy();
                [b2bService loadImagesForProduct:foundProduct block:^(NSMutableArray *images, NSError *error) {
                    DDLogDebug(@"Images count is %d", [images count]);
                    expect(images).to.beTruthy();
                    expect(error == nil);
                    done();
                }];
            }];
        }];
    });
    it(@"should retrieve the products in category", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService findCategoriesWithBlock:^(NSArray *foundCategories, NSError *error) {
            expect([foundCategories count] > 0).to.beTruthy();
            expect(error).to.beFalsy();
            HYBCategory *root = [foundCategories firstObject];
            expect(root).to.beTruthy;
            expect([root isRoot]).to.beTruthy();
            done();
        }];
    });
});

describe(@"Authentication", ^{
    beforeAll(^{
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        [NSBundle bundleWithPath:bundlePath];
    });
    it(@"should authenticate the user successfully", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        [b2bService authenticateUser:username password:password block:^(NSString *msg, NSError *error) {
            expect(msg).to.equal(NSLocalizedString(@"login_success", nil));
            expect(error).to.beFalsy();
            [b2bService logoutCurrentUser];
            done();
        }];
    });
    it(@"should not authenticate the user at failure", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        [b2bService logoutCurrentUser];
        
        [b2bService authenticateUser:username password:@"wrongPasswordForAuth" block:^(NSString *msg, NSError *error) {
            expect(msg).to.equal(NSLocalizedString(@"login_failed_wrong_credentials", nil));
            expect(error).to.beTruthy();
            done();
        }];
    });
    it(@"should obtain the token for user failure", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        [b2bService logoutCurrentUser];
        
        [b2bService retrieveToken:username password:@"wrongPasswordForTokenRetrieval" block:^(NSString *messageOrToken, NSError *error) {
            NSString *expected = NSLocalizedString(@"login_failed_checkcredentials_or_user_rights", nil);
            expect(messageOrToken).to.equal(expected);
            
            done();
        }];
    });
    it(@"should recognize not expired token", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        NSNumber *millisecondsToExpire = @10000;
        double secondsToExpire = millisecondsToExpire.doubleValue / 1000;
        NSDate *expirationTime = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsToExpire];
        NSDictionary *resposeValues = @{HYB2B_EXPIRATION_TIME_KEY : expirationTime};
        
        BOOL result = [b2bService isExpiredToken:resposeValues];
        expect(result).to.beFalsy();
        [b2bService logoutCurrentUser];
        done();
    });
    it(@"should obtain the token for user success and save it to properties", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        b2bService.userDefaults = userDefaults;
        
        NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        
        [b2bService retrieveToken:username password:password block:^(NSString *messageOrToken, NSError *error) {
            expect(messageOrToken).to.beTruthy();
            expect(error).to.beFalsy();
            
            NSDictionary *tokenData = [userDefaults objectForKey:username];
            expect(tokenData).to.beTruthy();
            expect([tokenData objectForKey:HYB2B_EXPIRATION_TIME_KEY]).to.beTruthy();
            
            // reconfigure the expiration time to be much shorter, for the next test
            NSMutableDictionary *newTokenData = [[NSMutableDictionary alloc] initWithDictionary:tokenData];
            [newTokenData setObject:now forKey:HYB2B_EXPIRATION_TIME_KEY];
            [userDefaults setObject:newTokenData forKey:username];
            
            // now reuse the previously saved token doing a refresh
            [b2bService retrieveToken:username password:password block:^(NSString *messageOrToken, NSError *error) {
                expect(error).to.beFalsy();
                expect(messageOrToken).to.beTruthy();
                
                NSDictionary *tokenData = [userDefaults objectForKey:username];
                expect(tokenData).to.beTruthy();
                expect([tokenData objectForKey:HYB2B_EXPIRATION_TIME_KEY] != now).to.beTruthy();
                
                [b2bService logoutCurrentUser];
                
                done();
            }];
        }];
    });
});

describe(@"Cart Management", ^{
    __block HYB2BService *backEndService;
    
    beforeAll(^{
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        [NSBundle bundleWithPath:bundlePath];
        
        backEndService = [[HYB2BService alloc] initWithDefaults];
        backEndService.userDefaults = [[NSUserDefaults alloc] init];
    });
    it(@"full checkout workflow", ^AsyncBlock {
        
        [backEndService authenticateUser:username password:password block:^(NSString *msg, NSError *error) {
            
            expect(msg).to.equal(NSLocalizedString(@"login_success", nil));
            expect(error).to.beFalsy();
            
            [backEndService retrieveCurrentCartAndExecute:^(HYBCart *cart, NSError *error) {
                expect(cart).to.beTruthy();
                
                [backEndService addProductToCurrentCart:TEST_PRODUCT_CODE amount:@5 block:^(HYBCart *cart, NSString *successMsg) {
                    expect(cart).to.beTruthy();
                    
                    [backEndService updateProductOnCurrentCartAmount:@"0" mount:@3 andExecute:^(HYBCart *cart, NSString *string) {
                        expect(cart).to.beTruthy();

                        
                        [backEndService setPaymentType:CART_PAYMENTTYPE_ACCOUNT onCartWithCode:cart.code execute:^(HYBCart *cart, NSError *successMsg) {
                            expect(cart.paymentTypeCode).to.equal(CART_PAYMENTTYPE_ACCOUNT);
                            
                            [backEndService costCentersForCurrentStoreAndExecute:^(NSArray *costCenter, NSError *err) {
                                expect(costCenter.count > 0).to.beTruthy();
                                
                                HYBCostCenter *center = costCenter.firstObject;
                                expect(center).to.beTruthy();
                                
                                [backEndService setCostCenterWithCode:center.code onCartWithCode:cart.code andExecute:^(HYBCart *cart, NSError *error) {
                                    expect(error).to.beFalsy();
                                    expect(cart.code).to.beTruthy();
                                    
                                    HYBAddress *addr = center.addresses.firstObject;
                                    expect(addr).to.beTruthy();
                                    
                                    [backEndService setDeliveryAddressWithCode:addr.id onCartWithCode:cart.code andExecute:^(HYBCart *cart, NSError *error) {
                                        expect(error).to.beFalsy();
                                        expect(cart).to.beTruthy();
                                        expect(cart.code).to.beTruthy();
                                        
                                        [backEndService getDeliveryModesForCart:cart.code andExecute:^(NSArray *modes, NSError *error) {
                                            expect(cart).to.beTruthy();
                                            expect(cart.code).to.beTruthy();
                                            expect(error).to.beFalsy();
                                            expect(modes.count > 0).to.beTruthy();
                                            HYBDeliveryMode *mode = modes.firstObject;
                                            
                                            [backEndService setDeliveryModeWithCode:mode.code onCartWithCode:cart.code andExecute:^(HYBCart *cart, NSError *error) {
                                                expect(error).to.beFalsy();
                                                expect(cart).to.beTruthy();
                                                expect(cart.code).to.beTruthy();
                                                
                                                [backEndService placeOrderWithCart:cart andExecute:^(HYBOrder *order, NSError *error) {
                                                    expect(error).to.beFalsy();
                                                    expect(order.code).to.beTruthy();
                                                    
                                                    [backEndService findOrderByCode:order.code andExecute:^(HYBOrder *order, NSError *error) {
                                                        HYBAddress *deliveryAddr = order.deliveryAddress;
                                                        HYBDeliveryMode *mode = order.deliveryMode;
                                                        
                                                        expect(deliveryAddr.formattedAddress).to.beTruthy();
                                                        expect(deliveryAddr.formattedAddressBreakLines).to.beTruthy();
                                                        expect(mode.name).to.beTruthy();
                                                        
                                                        done();
                                                    }];
                                                }];
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    });
});


describe(@"Multiple add products", ^{
    __block HYB2BService *backEndService;
    
    beforeAll(^{
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        [NSBundle bundleWithPath:bundlePath];
        
        backEndService = [[HYB2BService alloc] initWithDefaults];
        backEndService.userDefaults = [[NSUserDefaults alloc] init];
        
    });
    it(@"rapidly add the same product multiple time", ^AsyncBlock {
        
        [backEndService authenticateUser:username password:password block:^(NSString *msg, NSError *error) {
            
            expect(msg).to.equal(NSLocalizedString(@"login_success", nil));
            expect(error).to.beFalsy();
            
            double delayInSeconds = 2.0;
            dispatch_queue_t testQueue = dispatch_queue_create("testQueue", nil);
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, testQueue, ^(void){

                [backEndService retrieveCurrentCartAndExecute:^(HYBCart *cart, NSError *error) {
                    expect(cart).to.beTruthy();

                    __block int count = 0;
                    __block int maxCount = 10;
                    __block int totalAdded = 0;

                    [NSTimer bk_scheduledTimerWithTimeInterval:.2 block:^(NSTimer *timer) {

                        if (++count > maxCount) {

                            DDLogDebug(@"stop timer", totalAdded);

                            [timer invalidate];
                            timer = nil;

                            //delayed verification (wait for late callbacks)
                            double verificationDelayInSeconds = 3.0;
                            dispatch_queue_t doneQueue = dispatch_queue_create("doneQueue", nil);
                            dispatch_time_t secondPopTime = dispatch_time(DISPATCH_TIME_NOW, verificationDelayInSeconds * NSEC_PER_SEC);
                            dispatch_after(secondPopTime, doneQueue, ^(void) {
                                DDLogDebug(@"total added verification");
                                expect(maxCount).to.equal(totalAdded);
                                done();
                            });

                        } else {
                            DDLogDebug(@"try %d", count);

                            [backEndService addProductToCurrentCart:TEST_PRODUCT_CODE amount:@1 block:^(HYBCart *cart, NSString *successMsg) {
                                expect(cart).to.beTruthy();
                                expect(cart.code).to.beTruthy();
                                expect(error).to.beFalsy();

                                totalAdded++;

                                DDLogDebug(@"total items added %d", totalAdded);
                            }];
                        }
                    }                                  repeats:YES];
                }];
            });
        }];
    });
});


describe(@"Basic Rest-WS Features", ^{
    beforeAll(^{
    });
    it(@"should the proper error message from the web service response in error case", ^AsyncBlock {
        HYB2BService *b2bService = [[HYB2BService alloc] initWithDefaults];
        
        NSString *url = [b2bService productDetailsURLForProduct:@"wrongCode" insideStore:[b2bService currentStoreId]];
        [b2bService doGETWithUrl:url params:nil disableCache:YES block:^(MKNetworkOperation *JSON, NSError *error) {
            expect(error).to.beTruthy();
            expect(error.localizedDescription).to.equal(@"Product with code 'wrongCode' not found!");
            done();
        }];
    });
});
SpecEnd




