//
// HYBCartSpec.m
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
#import <Expecta/Expecta.h>
#import <RMMapper/NSUserDefaults+RMSaveCustomObject.h>
#import <BlocksKit/NSObject+BKAssociatedObjects.h>
#import "HYBCart.h"
#import "HYBCartItem.h"
#import "HYBProduct.h"
#import "HYBProductVariantOption.h"

SpecBegin(HYBCart)
     describe(@"NewHYBCart", ^{
        __block NSDictionary *json;
        __block HYBCart *cart;
        beforeAll(^{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"createCartSampleResponse" ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];

            json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            cart = [[HYBCart alloc] initWithParams:json baseStoreUrl:@"http://random.com"];
            expect(cart).to.beTruthy();
        });
        it(@"should create new cart from json", ^{
            expect(cart.code).to.beTruthy();
            expect([cart.totalItems intValue]).to.equal(0);
            expect([cart.totalPrice intValue]).to.equal(0);
        });
        it(@"should create present cart from json", ^{
            expect(cart.code).to.beTruthy();
            expect([cart.totalItems intValue]).to.equal(0);
            expect([cart.totalPrice intValue]).to.equal(0);
        });
    });
    describe(@"PresentHYBCart", ^{
            __block NSDictionary *json;
            __block HYBCart *cart;
            __block HYBCartItem *cartItem;
            beforeAll(^{
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"presentCartSampleResponse" ofType:@"json"];
                NSData *data = [NSData dataWithContentsOfFile:filePath];

                json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                cart = [[HYBCart alloc] initWithParams:json baseStoreUrl:@"http://random.com"];
                cartItem = [cart.items firstObject];
                expect(cart).to.beTruthy();
            });
            it(@"should create new cart from json", ^{
                expect(cart.code).to.beTruthy();
                expect(cart.code).to.beTruthy();
                expect([cart.totalItems intValue] > 0).to.beTruthy();
                expect(cart.totalPrice).to.equal(524.77);
                expect(cart.totalPriceFormatted).to.equal(@"$524.77");
                expect(cart.totalPriceWithTax).to.equal(524.77);
                expect(cart.totalUnitCount).to.equal(10);
                expect(cart.subTotalFormatted).to.equal(@"$541.00");
                expect(cart.orderDiscountsFormattedValue).to.equal(@"$16.23");
                NSString *msg = cart.orderDiscountsMessage;
                expect([msg isEqualToString:@"You saved $16.23 for spending over $500.00"]).to.beTruthy();
            });
            it(@"should contain the cart items", ^{
                expect(cart.items).to.beTruthy();
                expect(cart.items.count > 0).to.beTruthy();
            });
            it(@"should contain a proper items inside the items list", ^{
                expect(cartItem).to.beTruthy();
                HYBProduct *product = cartItem.product;
                expect(product).to.beTruthy();
                expect(product.code).to.beTruthy();
                expect(product.name).to.beTruthy();
                expect([cartItem.entryNumber intValue]).to.equal(0);
                expect(cartItem.quantity).to.equal(5);
                expect(cartItem.totalPriceFormattedValue).to.equal(@"$116.00");
                expect(cartItem.price).to.beTruthy();
                expect(cartItem.basePriceFormattedValue).to.beTruthy();
            });
            it(@"should handle a multid cartItem product", ^{
                cartItem = [cart.items lastObject];
                expect(cartItem).to.beTruthy();
                HYBProduct *product = cartItem.product;
                expect(product.multidimensional).to.beTruthy();
                expect(product.formattedPrice).to.equal(@"$85.00-$85.00");
            });
            it(@"should have dictionary representation of the cart cartItem", ^{
                expect(cartItem.asDictionary).to.beTruthy();
                expect([[cartItem.asDictionary allKeys] count]).to.beGreaterThan(0);
            });
            it(@"should save and retrieve the whole cart to archive", ^{
                NSString *cartKey = @"mySavedCartItem";
                NSUserDefaults *cache = [[NSUserDefaults alloc] init];
                [cache rm_setCustomObject:cartItem forKey:cartKey];
                HYBCartItem *retrievedItem = [cache rm_customObjectForKey:cartKey];
                expect(retrievedItem).to.beTruthy();
                expect(retrievedItem.product).to.beTruthy();
                [cache removeObjectForKey:cartKey];
            });
            it(@"should the payment type", ^{
                NSString *paymentTypeCode = cart.paymentTypeCode;
                NSString *paymentTypeDescription = cart.paymentDisplayName;
                expect(paymentTypeCode).to.beTruthy();
                expect(paymentTypeDescription).to.beTruthy();
            });
    });
     describe(@"PresentHYBCartFromGetCartsList", ^{
         __block NSDictionary *json;
         __block HYBCart *cart;
         __block HYBCartItem *cartItem;
         beforeAll(^{
             NSString *filePath = [[NSBundle mainBundle] pathForResource:@"getCartsSampleResponse" ofType:@"json"];
             NSData *data = [NSData dataWithContentsOfFile:filePath];

             json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

             NSDictionary *cartJson = [[json objectForKey:@"carts"] firstObject];
             expect(cartJson).to.beTruthy();
             cart = [[HYBCart alloc] initWithParams:cartJson baseStoreUrl:@"http://random.com"];
             cartItem = [cart.items firstObject];
             expect(cart).to.beTruthy();
         });
         it(@"should create new cart from json", ^{
             expect(cart.code).to.beTruthy();
             expect(cart.code).to.beTruthy();
             expect([cart.totalItems intValue] > 0).to.beTruthy();
             expect(cart.totalPrice).to.beTruthy();
             expect(cart.totalPriceFormatted).to.beTruthy();
             expect(cart.totalPriceWithTax).to.equal(884.64);
             expect(cart.totalUnitCount).to.equal(22);
             expect(cart.subTotalFormatted).to.equal(@"$912.00");

         });
         it(@"should contain the cart items", ^{
             expect(cart.items).to.beTruthy();
             expect(cart.items.count > 0).to.beTruthy();
         });
         it(@"should contain a proper items inside the items list", ^{
             expect(cartItem).to.beTruthy();
             HYBProduct *product = cartItem.product;
             expect(product).to.beTruthy();
             expect(product.code).to.beTruthy();
             expect(product.name).to.beTruthy();
             expect([cartItem.entryNumber intValue]).to.equal(0);
             expect(cartItem.quantity).to.equal(10);
             expect(cartItem.totalPriceFormattedValue).to.beTruthy();
             expect(cartItem.price).to.beTruthy();
             expect(cartItem.basePriceFormattedValue).to.beTruthy();
             NSString *itemDiscount = cartItem.discountMessage;
             expect(itemDiscount).to.beTruthy();
         });
         it(@"should contain order promotions and cart item discounts", ^{
             expect(cart.orderDiscountsFormattedValue).to.equal(@"$27.36");
             expect(@"You saved $16.23 for spending over $500.00").to.equal(@"You saved $16.23 for spending over $500.00");

             cartItem = [cart.items firstObject];
             expect(cartItem.discountMessage).to.beTruthy();

             cartItem = [cart.items objectAtIndex:1];
             expect(cartItem.discountMessage).to.beTruthy();
         });
         it(@"should have dictionary representation of the cart cartItem", ^{
             expect(cartItem.asDictionary).to.beTruthy();
             expect([[cartItem.asDictionary allKeys] count]).to.beGreaterThan(0);
         });
         it(@"should save and retrieve the whole cart to archive", ^{
             NSString *cartKey = @"mySavedCartItem";
             NSUserDefaults *cache = [[NSUserDefaults alloc] init];
             [cache rm_setCustomObject:cartItem forKey:cartKey];
             HYBCartItem *retrievedItem = [cache rm_customObjectForKey:cartKey];
             expect(retrievedItem).to.beTruthy();
             expect(retrievedItem.product).to.beTruthy();
             [cache removeObjectForKey:cartKey];
         });
     });
SpecEnd
