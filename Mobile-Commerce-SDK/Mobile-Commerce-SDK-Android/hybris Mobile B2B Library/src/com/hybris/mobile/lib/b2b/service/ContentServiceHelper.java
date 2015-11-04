/*******************************************************************************
 * [y] hybris Platform
 *  
 *   Copyright (c) 2000-2014 hybris AG
 *   All rights reserved.
 *  
 *   This software is the confidential and proprietary information of hybris
 *   ("Confidential Information"). You shall not disclose such Confidential
 *   Information and shall use it only in accordance with the terms of the
 *   license agreement you entered into with hybris.
 ******************************************************************************/
package com.hybris.mobile.lib.b2b.service;

import java.util.List;

import android.view.View;
import android.widget.ImageView;

import com.hybris.mobile.lib.b2b.data.Category;
import com.hybris.mobile.lib.b2b.data.DeliveryMode;
import com.hybris.mobile.lib.b2b.data.UserInformation;
import com.hybris.mobile.lib.b2b.data.cart.Cart;
import com.hybris.mobile.lib.b2b.data.cart.ProductAdded;
import com.hybris.mobile.lib.b2b.data.costcenter.CostCenter;
import com.hybris.mobile.lib.b2b.data.order.Order;
import com.hybris.mobile.lib.b2b.data.product.Product;
import com.hybris.mobile.lib.b2b.data.product.ProductList;
import com.hybris.mobile.lib.b2b.query.QueryCart;
import com.hybris.mobile.lib.b2b.query.QueryLogin;
import com.hybris.mobile.lib.b2b.query.QueryPlaceOrder;
import com.hybris.mobile.lib.b2b.query.QueryProductDetails;
import com.hybris.mobile.lib.b2b.query.QueryProducts;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;


/**
 * Interface for the service used to get the application data
 */
public interface ContentServiceHelper
{

	/**
	 * Login a user
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param queryLogin
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean login(ResponseReceiver<UserInformation> responseReceiver, String requestId, QueryLogin queryLogin,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Refresh the user token
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param refreshToken
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean refreshToken(ResponseReceiver<UserInformation> responseReceiver, String refreshToken) throws IllegalArgumentException;

	/**
	 * Logout the current logged in user associated with the content service helper. Please note that this method is not
	 * asynchronous as we are doing any http call.
	 * 
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean logout();

	/**
	 * Return a catalog
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean getCatalog(ResponseReceiver<List<Category>> responseReceiver, String requestId, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * Return a list of products
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param queryProducts
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean getProducts(ResponseReceiver<ProductList> responseReceiver, String requestId, QueryProducts queryProducts,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Return the product information
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param queryProductDetails
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean getProductDetails(ResponseReceiver<Product> responseReceiver, String requestId,
			QueryProductDetails queryProductDetails, boolean shouldUseCache, List<View> viewsToDisable,
			OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Add product to cart with quantity
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param queryCart
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean addProductToCart(ResponseReceiver<ProductAdded> responseReceiver, String requestId, QueryCart queryCart,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Update cart entry quantity
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param queryCart
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean updateCartEntry(ResponseReceiver<ProductAdded> responseReceiver, String requestId, QueryCart queryCart,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Delete a cart entry
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param queryCart
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean deleteCartEntry(ResponseReceiver<ProductAdded> responseReceiver, String requestId, QueryCart queryCart,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Create a cart for the logged user
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean createCart(ResponseReceiver<Cart> responseReceiver, String requestId, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * Get default cart of the user
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean getCart(ResponseReceiver<Cart> responseReceiver, String requestId, boolean shouldUseCache, List<View> viewsToDisable,
			OnRequestListener onRequestListener);

	/**
	 * Get the delivery modes
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean getDeliveryModes(ResponseReceiver<List<DeliveryMode>> responseReceiver, String requestId, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * Update delivery mode for the current cart
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param deliveryMode
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean updateCartDeliveryMode(ResponseReceiver<Cart> responseReceiver, String requestId, String deliveryMode,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * Get the cost centers list
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean getCostCenters(ResponseReceiver<List<CostCenter>> responseReceiver, String requestId, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * Set the cost center for the current cart
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param costCenterId
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean updateCartCostCenter(ResponseReceiver<Cart> responseReceiver, String requestId, String costCenterId,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * Update the payment type for the current cart
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param paymentType
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean updateCartPaymentType(ResponseReceiver<Cart> responseReceiver, String requestId, String paymentType,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * 
	 * Update the delivery address for the current cart
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param addressId
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean updateCartDeliveryAddress(ResponseReceiver<Cart> responseReceiver, String requestId, String addressId,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Place an Order
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param queryPlaceOrder
	 *           Parameters needed for the request
	 * @param requestId
	 *           Identifier for the call
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean placeOrder(ResponseReceiver<Order> responseReceiver, String requestId, QueryPlaceOrder queryPlaceOrder,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException;

	/**
	 * Return order's information
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param requestId
	 *           Identifier for the call
	 * @param orderNumber
	 *           Parameters needed for the request
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	boolean getOrder(ResponseReceiver<Order> responseReceiver, String requestId, String orderNumber, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener);

	/**
	 * Load an image into an ImageView
	 * 
	 * @param url
	 *           HTTP Address
	 * @param requestId
	 *           Identifier for the call
	 * @param imageView
	 *           ImageView to be updated
	 * @param width
	 *           Horizontal size in pixels (or 0 for automatic)
	 * @param height
	 *           Vertical size in pixels (or 0 for automatic)
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @param forceImageTagToMatchRequestId
	 *           if set to true, the imageView will set its tag with the requestId value and will verify after getting
	 *           the image content from the url, that the tag is still equals to the requestId. If yes, the imageView is
	 *           updated with the content just pulled.
	 * @return true if no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 * @throws IllegalArgumentException
	 */
	boolean loadImage(String url, String requestId, ImageView imageView, int width, int height, boolean shouldUseCache,
			OnRequestListener onRequestListener, boolean forceImageTagToMatchRequestId) throws IllegalArgumentException;

	/**
	 * Cancel the requests associated with the id
	 */
	void cancel(String requestId);

	/**
	 * Pause all the current requests
	 */
	void pause();

	/**
	 * (Re)Start all the (pending) requests
	 */
	void start();

}
