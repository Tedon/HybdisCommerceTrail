//
// HYBBackEndFacade.h
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
#import "HYBBackEndFacade.h"

@class HYBProduct;
@class HYBCategory;
@class HYBCart;
@class HYBOrder;

static NSString *const LAST_AUTHENTICATED_USER_KEY = @"last_authenticated_user";
static NSString *const PREVIOUSLY_AUTHENTICATED_USER_KEY = @"previously_authenticated_user";

/**
* The HYBBackEndFacade provides a clear separate api to communicate with the back end.
*
* The service implementing this api can usually be a web service communicating to the hybris server.
*
* This API should usually be used by controllers inside the MVC pattern.
*/

static NSString *const USE_CACHE_ATTRIBUTE_KEY = @"backend_usecache";
static NSString *const REST_URL_ATTRIBUTE_KEY = @"backend_restversion_prefix";
static NSString *const HOST_ATTRIBUTE_KEY = @"backend_host";
static NSString *const PORT_ATTRIBUTE_KEY = @"backend_port";

extern NSString * const NOTIFICATION_CART_UPDATED;

/**
* The main back end interface implemented with the Facade pattern to clearly separate front end from back end layers.
* Implement this interface to extend the back end or add a domain specific implementation like b2b or b2c.
*
* The facade covers several services and makes them transparent to the client of this facade. This is usually an
* MVC based front end. Use this facade combined with dependency injection to reach maximum extensibility and
* testability.
*/
@protocol HYBBackEndFacade <NSObject>

@required

/**
* This will initialize the service api.
*/
- (id)initWithDefaults;

/**
* Will find all products. Pagination will be added in later versions.
*
* @param block The block that will be executed after the method is processed. The array inside the block
* will hold the found products, if any error occurs, the variable with the type NSError will contain the
* error information.
*
* @return void, but the actual return is considered to be in the NSArray inside the block
*/
- (void)findProductsWithBlock:(void (^)(NSArray *, NSError *))block;

/**
* Will find a product by id.
*
* @param block The block that will be executed after the method is processed. The product inside the block
* will hold the found product, if any error occurs, the variable with the type NSError will contain the
* error information.
*
* @return void, but the actual return is considered to be in the product inside the block
*/
- (void)findProductById:(NSString *)productId withBlock:(void (^)(HYBProduct *, NSError *))block;

/**
* Will authenticate a user with the provided credentials
*
* @param user The user id to use as credential
* @param pass The password for this user
* @param block The block that will be executed if the login was successful, the NSString variable will hold the message
* from the system, e.g. that the authentication was successful or not, the NSError will hold the error if an error occurs.
*/
- (void)authenticateUser:(NSString *const)user password:(NSString *)pass block:(void (^)(NSString *, NSError *))block;


/**
* Will retrieve all customer groups for the given user
*
* @param user The user id to use as credential
* @param token The token for this user, usually handled by the web service to handle the authentication
* @param block The block that will be executed if the login was successful, the NSString variable will hold the message
* from the system, e.g. that the authentication was successful or not, the NSError will hold the error if an error occurs.
*/
- (void)fetchCustomerGroupsFor:(NSString *)user token:(NSString *)token block:(void (^)(NSArray *, NSError *))block;

/**
* Will retrieve the token for the provided credentials
*
* @param user The user id to use as credential
* @param pass The password for this user
* @param block The block that will be executed if the login was successful, the NSString variable will hold the resulting
* token for the user, the NSError will hold the error if an error occurs.
*/
- (void)retrieveToken:(NSString *)user password:(NSString *)pass block:(void (^)(NSString *, NSError *))block;

/**
* Will load an image for the given image url
*
* @param url The url for the image to download
* @param block The block that will be executed if the login was successful, the UIImage variable will hold the image
* , the NSError will hold the error if an error occurs.
*/
- (void)loadImageByUrl:(NSString *)url block:(void (^)(UIImage *, NSError *))block;


/**
 * Handle pagination
 */

/**
 *  Will set the page offset to 0 to start the pagination again
 */
- (void)resetPagination;


/**
 *  Will increase the offset value
 */
- (void)nextPage;

/**
 *  Returns the current page in the pagination procedure
 *
 *  @return size of the current page
 */
- (int)currentPage;

/**
 *  How many products are returned for one pagination call in the search result
 *
 *  @return number of products on a page
 */
- (int)pageSize;

/**
 *  The total search results number combined of all pagination pages
 *
 *  @return total search results
 */
- (int)totalSearchResults;

/**
 *  Will find all categories in the current catalog.
 *
 *  @param block The block that will be executed after the method is processed. The array inside the block
 * will hold the found categories, if any error occurs, the variable with the type NSError will contain the
 * error information.
 */
- (void)findCategoriesWithBlock:(void (^)(NSArray *, NSError *))block;

/**
* Will find all products inside the given category by category Id and execute the given block
* using the result. The resulting categories will be passed to the block inside the foundCategories variable.
* If an error occurs it will be passed to the block.
*
* @param The categoryId that will be used to search the products
* @param Code block to execute after the find action is performed
*/
- (void)findProductsByCategoryId:(NSString *)categoryId withBlock:(void (^)(NSArray *foundCategories, NSError *error))block;

/**
 *  Will search for products by the given search query.
 *
 *  @param query     The query wich can be a part string for key words from description a product name or product code
 *  @param toExecute The block of code that will be executed after the search is performed, the found products will be saved to the array passed within the block. In case of an error the error object will be populated with the error info.
 */
- (void)findProductsBySearchQuery:(NSString *)query andExecute:(void (^)(NSArray *foundProducts, NSString *spellingSuggestion, NSError *error))toExecute;

/**
 *  Load images for a given product
 *
 *  @param product The product object that the images will be loaded for
 *  @param block   Code to execute if the loading of images is done, the images are saved to the images array inside the block
 */
- (void)loadImagesForProduct:(HYBProduct *)product block:(void (^)(NSMutableArray *images, NSError *error))block;

/**
 *  Add a given product to the cart
 *
 *  @param productCode The code of the product to add
 *  @param amount      Items amount of the product that should be added
 *  @param toExecute   Code that will be executed after the action is performed, the updated cart with the added product will be passed into the block
 */
- (void)addProductToCurrentCart:(NSString *)productCode amount:(NSNumber *)amount block:(void (^)(HYBCart *cart, NSString *msg))toExecute;

/**
 *  Retrieve cart for the user identified by the username, if no cart is present a new one will be created.
 *
 *  @param username  The user id that the cart should be retrieved or created.
 *  @param toExecute Code to execute after the cart retrieval, the found cart is passed to the block. If error occures cart will be set to nil and error will be passed to the block
 */
- (void)retrieveCartByUserIdFromCurrentCartsCreateIfNothingPresent:(NSString *)username andExecute:(void (^)(HYBCart *, NSError *))toExecute;

/**
 *  Retrieve the cart for the currently logged in user.
 *
 *  @param toExecute Code to execute after the retrieval, found cart is passed to the block or the error if it occures
 */
- (void)retrieveCurrentCartAndExecute:(void (^)(HYBCart *, NSError *))toExecute;

/**
 *  Create a cart for a user identified by the userId
 *
 *  @param userId    The id of the user to create the cart for
 *  @param toExecute Code to execute after the retrieval, found cart is passed to the block or the error if it occures
 */
- (void)createCartForUser:(NSString *)userId andExecute:(void (^)(HYBCart *, NSError *))toExecute;


/// @name Checkout flow

/**
 *  Setting the payment type on the cart
 *
 *  @param paymentType The payment type, find the defined payment type on the HYBCart type
 *  @param code        The code of the cart the payment method will be set on
 *  @param toExecute   Code to execute after the action is perfomed, updated cart or an error will be passed to the block
 */
- (void)setPaymentType:(NSString *)paymentType onCartWithCode:(NSString *)code execute:(void (^)(HYBCart *, NSError *))toExecute;

/**
 *  List cost centers inside the current store
 *
 *  @param toExecute Code to execute after the cost centers are retrieved, found cost centers will be passed within an array to the list.
 */
- (void)costCentersForCurrentStoreAndExecute:(void (^)(NSArray *, NSError *))toExecute;

/**
 *  Will set the address for delivery on the given cart with code
 *
 *  @param addressId The address id of the address object
 *  @param cartCode  The code of the cart to be set
 *  @param toExecute Code to execute after the action, updated cart or an occured error will be passed to the block
 */
- (void)setDeliveryAddressWithCode:(NSString *)addressId onCartWithCode:(NSString *)cartCode andExecute:(void (^)(HYBCart *, NSError *))toExecute;


/**
 *  Set eh cost center on the cart with a given code
 *
 *  @param costCenterCode The cost center code
 *  @param cartCode       The cart code
 *  @param execute        Code to execute after the action, updated cart or an occured error will be passed to the block
 */
- (void)setCostCenterWithCode:(NSString *)costCenterCode onCartWithCode:(NSString *)cartCode andExecute:(void (^)(HYBCart *, NSError *))execute;

/**
 *  Retrieve all delivery modes for the cart with a given cart code.
 *
 *  @param cartCode  The cart code to retrieve the delivery modes for
 *  @param toExecute Code to execute after the action, updated cart or an occured error will be passed to the block
 */
- (void)getDeliveryModesForCart:(NSString *)cartCode andExecute:(void (^)(NSArray *, NSError *))toExecute;

/**
 *  Set the delivery mode with code on the given cart
 *
 *  @param modeCode The code of the delivery mode, @see getDeliveryModesForCart to retrieve the available delivery modes
 *  @param cartCode The cart code to retrieve the cart
 *  @param execute  Code to execute after the action, updated cart or an occured error will be passed to the block
 */
- (void)setDeliveryModeWithCode:(NSString *)modeCode onCartWithCode:(NSString *)cartCode andExecute:(void (^)(HYBCart *, NSError *))execute;

/**
 *  Place the order of the configured cart. @warning you need to configure all cart attributes before you can place the order see the code samples provided in the app or inside the test
 *
 *  @param cart    The cart object of the cart that will be place, @see retrieveCartByUserIdFromCurrentCartsCreateIfNothingPresent to retrieve a cart for a present cart code
 *  @param execute Code to execute after the action, placed order or an occured error will be passed to the block
 */
- (void)placeOrderWithCart:(HYBCart *)cart andExecute:(void (^)(HYBOrder *, NSError *))execute;

/**
 *  Attribute indicating if the cache is used or not in the back end to save the responses from the server
 *
 *  @return Boolean value indicated if cache is used or not
 */
- (BOOL)isUsingCache;

/**
 *  Logout the current user, all user data on the app and in the cache will be erased
 */
- (void)logoutCurrentUser;

/**
 *  Direct access to the userStora, mostly the @see NSUserDefaults of the app to save basic settings and be able to do dependency injection for the back end service
 *
 *  @return the userStorage object
 */
- (NSUserDefaults *)userStorage;

/**
 *  During the cart interaction the lastest user cart is saved in the cache, so no web service call are needed if the cart is providing information to its consumers in the front end.
 *  This method should be used to retrieve the cart data and pass it to the several points in the front end.
 *
 *  @return The last cart that was saved in the back end cache and came from the back end server
 */
- (HYBCart *)currentCartFromCache;

/**
 *  The user email of the current user, the email is usually used as the user key within the app
 *
 *  @return The email of the current user
 */
- (NSString *)currentUserEmail;

/**
 *  Update a product amount of a product that was already added to the cart.
 *
 *  @param entryNumber The product entry number within the cart to identify the product within others
 *  @param amountToAdd The items amount to adjust. If 0 amount is given, the product will be deleted from the cart
 *  @param toExecute   Code to execute after the action, updated cart or an occured error will be passed to the block
 */
- (void)updateProductOnCurrentCartAmount:(NSString *)entryNumber mount:(NSNumber *)amountToAdd andExecute:(void (^)(HYBCart *, NSString *))toExecute;

/**
 *  Delete the cart for the user by cart and user id
 *
 *  @param userId  The userId tha holds the cart to delete
 *  @param cartId  The cart id to delete the cart
 *  @param execute Code to execute after the action, updated message or an occured error will be passed to the block
 */
- (void)deleteCartForUser:(NSString *)userId byCartId:(NSString *)cartId executeWith:(void (^)(NSString *, NSError *))execute;
@end