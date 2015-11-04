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

import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap.Config;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;

import com.hybris.mobile.lib.b2b.Constants;
import com.hybris.mobile.lib.b2b.R;
import com.hybris.mobile.lib.b2b.data.Category;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.DataError.ErrorMessage;
import com.hybris.mobile.lib.b2b.data.DeliveryMode;
import com.hybris.mobile.lib.b2b.data.UserInformation;
import com.hybris.mobile.lib.b2b.data.cart.Cart;
import com.hybris.mobile.lib.b2b.data.cart.ProductAdded;
import com.hybris.mobile.lib.b2b.data.costcenter.CostCenter;
import com.hybris.mobile.lib.b2b.data.order.Order;
import com.hybris.mobile.lib.b2b.data.product.Product;
import com.hybris.mobile.lib.b2b.data.product.ProductList;
import com.hybris.mobile.lib.b2b.helper.SecurityHelper;
import com.hybris.mobile.lib.b2b.helper.UrlHelper;
import com.hybris.mobile.lib.b2b.query.QueryCart;
import com.hybris.mobile.lib.b2b.query.QueryFacet;
import com.hybris.mobile.lib.b2b.query.QueryLogin;
import com.hybris.mobile.lib.b2b.query.QueryPlaceOrder;
import com.hybris.mobile.lib.b2b.query.QueryProductDetails;
import com.hybris.mobile.lib.b2b.query.QueryProducts;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.PersistenceHelper;
import com.hybris.mobile.lib.http.converter.DataConverter;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.manager.PersistenceManager;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.http.response.ResponseCallback;
import com.hybris.mobile.lib.http.utils.HttpUtils;


/**
 * OCC Implementation to retrieve the application data
 */
public class OCCServiceHelper implements ContentServiceHelper
{
	private static final String TAG = OCCServiceHelper.class.getCanonicalName();
	private static final Config CONFIG_IMAGES_QUALITY = Config.ALPHA_8;
	private static final String HEADER_AUTHORIZATION = "Authorization";
	private static final String HEADER_AUTHORIZATION_BEARER = "Bearer";
	private static final String TOKEN_REFRESH = "TOKEN_REFRESH";
	private static final String USER_ID = "USER_ID";

	private UserInformation mUserInformation;
	private PersistenceHelper mPersistenceHelper;
	private Context mContext;

	private enum CartActionEnum
	{
		ADD, UPDATE, DELETE;
	}

	public OCCServiceHelper(Context context, PersistenceManager persistenceManager, DataConverter dataConverter)
	{

		if (context == null || persistenceManager == null || dataConverter == null)
		{
			throw new IllegalArgumentException();
		}

		this.mContext = context;
		this.mPersistenceHelper = new PersistenceHelper(context, persistenceManager, dataConverter);

		// We initiate the user's informations with the date previously saved if any
		this.mUserInformation = new UserInformation(SecurityHelper.getStringFromSecureSharedPreferences(getSharedPreferences(),
				USER_ID, ""), SecurityHelper.getStringFromSecureSharedPreferences(getSharedPreferences(), TOKEN_REFRESH, ""));
	}

	/**
	 * Update the UserAuthorization object used by authenticated requests
	 * 
	 * @param userInformation
	 * @param userId
	 */
	private void saveUserInformation(UserInformation userInformation, String userId)
	{
		userInformation.setIssuedOn(Calendar.getInstance().getTimeInMillis());
		this.mUserInformation = userInformation;
		this.mUserInformation.setUserId(userId);

		// Save needed user information in the shared preferences in case the app is restarted
		SecurityHelper
				.setStringToSecureSharedPreferences(getSharedPreferences(), TOKEN_REFRESH, userInformation.getRefresh_token());
		SecurityHelper.setStringToSecureSharedPreferences(getSharedPreferences(), USER_ID, userId);
	}

	/**
	 * Get the shared preferences
	 * 
	 * @return
	 */
	private SharedPreferences getSharedPreferences()
	{
		return PreferenceManager.getDefaultSharedPreferences(mContext);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#login(com.hybris.mobile.lib.http.response.ResponseReceiver,
	 * java.lang.String, com.hybris.mobile.lib.b2b.query.QueryLogin, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean login(final ResponseReceiver<UserInformation> responseReceiver, final String requestId,
			final QueryLogin queryLogin, boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener)
			throws IllegalArgumentException
	{

		if (queryLogin == null || StringUtils.isBlank(queryLogin.getUsername()))
		{
			throw new IllegalArgumentException();
		}

		// Constructing the parameters map
		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("grant_type", "password");
		parameters.put("username", queryLogin.getUsername());
		parameters.put("password", queryLogin.getPassword());

		// Constructing the headers map
		Map<String, String> headers = new HashMap<String, String>();
		String authString = "mobile_android:secret";
		String authValue = "Basic " + Base64.encodeToString(authString.getBytes(), Base64.NO_WRAP);
		headers.put("Authorization", authValue);

		// We want to save the user information before sending back the result
		ResponseReceiver<UserInformation> responseReceiverBeforeCallback = new ResponseReceiver<UserInformation>()
		{

			@Override
			public void onResponse(Response<UserInformation> response)
			{
				// Saving the user information for future authorized requests
				saveUserInformation(response.getData(), queryLogin.getUsername());
				responseReceiver.onResponse(response);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				responseReceiver.onError(response);
			}
		};

		return execute(responseReceiverBeforeCallback, DataConverter.Helper.build(UserInformation.class, DataError.class, null),
				shouldUseCache, requestId, mContext.getString(R.string.url_token), parameters, headers, false,
				HttpUtils.HTTP_METHOD_POST, viewsToDisable, onRequestListener);

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#refreshToken(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String)
	 */
	@Override
	public boolean refreshToken(ResponseReceiver<UserInformation> responseReceiver, String refreshToken)
			throws IllegalArgumentException
	{
		if (mUserInformation == null || mUserInformation.isTokenExpired() || mUserInformation.isTokenInvalid())
		{
			// Constructing the parameters map
			Map<String, String> parameters = new HashMap<String, String>();
			parameters.put("grant_type", "refresh_token");
			parameters.put("refresh_token", refreshToken);
			parameters.put("client_id", "mobile_android");
			parameters.put("client_secret", "secret");

			return execute(responseReceiver, DataConverter.Helper.build(UserInformation.class, DataError.class, null), false, null,
					mContext.getString(R.string.url_token), parameters, null, false, HttpUtils.HTTP_METHOD_POST, null, null);
		}
		else if (responseReceiver != null)
		{
			responseReceiver.onResponse(Response.createResponse(mUserInformation, null, true));
			return true;
		}
		else
		{
			return false;
		}

	}

	/**
	 * Send a broadcast message for logout
	 * 
	 */
	private void sendLogoutBroadcast() throws IllegalArgumentException
	{
		LocalBroadcastManager.getInstance(mContext).sendBroadcast(new Intent(mContext.getString(R.string.intent_action_logout)));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#logout()
	 */
	@Override
	public boolean logout()
	{
		Log.i(TAG, "Logging out");
		mUserInformation = new UserInformation();
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#getCatalog(com.hybris.mobile.lib.http.response.ResponseReceiver
	 * , java.lang.String, boolean, java.util.List, com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean getCatalog(ResponseReceiver<List<Category>> responseReceiver, String requestId, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		return executeForList(responseReceiver, DataConverter.Helper.build(Category.class, DataError.class, "subcategories"),
				shouldUseCache, requestId,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_catalogs, mContext.getString(R.string.default_categories)),
				null, null, false, HttpUtils.HTTP_METHOD_GET, viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#getProducts(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String, com.hybris.mobile.lib.b2b.query.QueryProducts, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean getProducts(ResponseReceiver<ProductList> responseReceiver, String requestId, QueryProducts queryProducts,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException
	{
		if (queryProducts == null)
		{
			throw new IllegalArgumentException();
		}

		// Getting the facets from the query object
		StringBuilder query = new StringBuilder();

		// Free text
		if (StringUtils.isNotBlank(queryProducts.getSearchText()))
		{
			query.append(queryProducts.getSearchText());
		}

		// Facets
		if (queryProducts.getQueryFacets() != null)
		{
			for (QueryFacet queryFacet : queryProducts.getQueryFacets())
			{
				query.append(":" + queryFacet.getName() + ":" + queryFacet.getValue());
			}
		}

		// Constructing the parameters map
		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("query", query.toString());
		parameters.put("pageSize", queryProducts.getPageSize() + "");
		parameters.put("currentPage", queryProducts.getCurrentPage() + "");

		return execute(responseReceiver, DataConverter.Helper.build(ProductList.class, DataError.class, null), shouldUseCache,
				requestId, UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_products, StringUtils.isBlank(queryProducts
						.getIdCategory()) ? mContext.getString(R.string.default_categories) : queryProducts.getIdCategory()),
				parameters, null, false, HttpUtils.HTTP_METHOD_GET, viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#getProductDetails(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String, com.hybris.mobile.lib.b2b.query.QueryProductDetails, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean getProductDetails(ResponseReceiver<Product> responseReceiver, String requestId,
			QueryProductDetails queryProductDetails, boolean shouldUseCache, List<View> viewsToDisable,
			OnRequestListener onRequestListener) throws IllegalArgumentException
	{

		if (queryProductDetails == null || StringUtils.isBlank(queryProductDetails.getCode()))
		{
			throw new IllegalArgumentException();
		}

		return execute(responseReceiver, DataConverter.Helper.build(Product.class, DataError.class, null), shouldUseCache,
				requestId, UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_product_details, queryProductDetails.getCode()),
				null, null, false, HttpUtils.HTTP_METHOD_GET, viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#addProductToCart(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String, com.hybris.mobile.lib.b2b.query.QueryCart, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean addProductToCart(final ResponseReceiver<ProductAdded> responseReceiver, final String requestId,
			final QueryCart queryCart, final boolean shouldUseCache, final List<View> viewsToDisable,
			final OnRequestListener onRequestListener) throws IllegalArgumentException
	{
		return addUpdateDeleteProductToCart(CartActionEnum.ADD, responseReceiver, requestId, queryCart, shouldUseCache,
				viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#updateCartEntry(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String, com.hybris.mobile.lib.b2b.query.QueryCart, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean updateCartEntry(final ResponseReceiver<ProductAdded> responseReceiver, final String requestId,
			final QueryCart queryCart, final boolean shouldUseCache, final List<View> viewsToDisable,
			final OnRequestListener onRequestListener) throws IllegalArgumentException
	{
		return addUpdateDeleteProductToCart(CartActionEnum.UPDATE, responseReceiver, requestId, queryCart, shouldUseCache,
				viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#deleteCartEntry(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String, com.hybris.mobile.lib.b2b.query.QueryCart, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean deleteCartEntry(final ResponseReceiver<ProductAdded> responseReceiver, final String requestId,
			final QueryCart queryCart, final boolean shouldUseCache, final List<View> viewsToDisable,
			final OnRequestListener onRequestListener) throws IllegalArgumentException
	{
		return addUpdateDeleteProductToCart(CartActionEnum.DELETE, responseReceiver, requestId, queryCart, shouldUseCache,
				viewsToDisable, onRequestListener);
	}

	/**
	 * Add, Update, or Delete a product
	 * 
	 * @param cartActionEnum
	 *           The action: ADD, UPDATE, DELETE
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
	private boolean addUpdateDeleteProductToCart(final CartActionEnum cartActionEnum,
			final ResponseReceiver<ProductAdded> responseReceiver, final String requestId, final QueryCart queryCart,
			final boolean shouldUseCache, final List<View> viewsToDisable, final OnRequestListener onRequestListener)
			throws IllegalArgumentException
	{

		if (queryCart == null || StringUtils.isBlank(queryCart.getProduct()))
		{
			throw new IllegalArgumentException();
		}

		// For the add and update we need a quantity
		if (!cartActionEnum.equals(CartActionEnum.DELETE) && queryCart.getQuantity() <= 0)
		{
			throw new IllegalArgumentException();
		}

		// We get the user's cart first if it was not already pulled
		if (StringUtils.isBlank(mUserInformation.getCartId()))
		{

			ResponseReceiver<Cart> responseReceiverGetCart = new ResponseReceiver<Cart>()
			{

				@Override
				public void onResponse(Response<Cart> response)
				{
					addUpdateDeleteProductToCart(cartActionEnum, responseReceiver, requestId, queryCart, shouldUseCache,
							viewsToDisable, onRequestListener);
				}

				@Override
				public void onError(Response<DataError> response)
				{
					responseReceiver.onError(response);
				}
			};

			return getCart(responseReceiverGetCart, requestId, shouldUseCache, viewsToDisable, onRequestListener);

		}
		else
		{

			// Intermediate receiver to handle errors
			ResponseReceiver<ProductAdded> responseReceiverCheckErrors = new ResponseReceiver<ProductAdded>()
			{

				@Override
				public void onResponse(Response<ProductAdded> response)
				{
					responseReceiver.onResponse(response);
				}

				@Override
				public void onError(Response<DataError> response)
				{
					// Cart not found error, probably because the cart had been checked out from another endpoint
					if (StringUtils.equals(response.getData().getErrorMessage().getReason(), Constants.ERROR_REASON_CART_NOT_FOUND)
							&& StringUtils.equals(response.getData().getErrorMessage().getType(), Constants.ERROR_TYPE_CART_ERROR))
					{
						// We reset the cart and re-call the method
						mUserInformation.setCartId(null);
						addUpdateDeleteProductToCart(cartActionEnum, responseReceiver, requestId, queryCart, shouldUseCache,
								viewsToDisable, onRequestListener);
					}
					else
					{
						responseReceiver.onError(response);
					}
				}

			};

			boolean returnResult = true;

			// Constructing the parameters map
			final Map<String, String> parameters = new HashMap<String, String>();

			switch (cartActionEnum)
			{
				case ADD:
					parameters.put("product", queryCart.getProduct());
					parameters.put("quantity", queryCart.getQuantity() + "");

					returnResult = execute(responseReceiverCheckErrors, DataConverter.Helper.build(ProductAdded.class,
							DataError.class, null), shouldUseCache, requestId, UrlHelper.getWebserviceCatalogUrl(mContext,
							R.string.path_add_to_cart, mUserInformation.getUserId(), mUserInformation.getCartId()), parameters, null,
							true, HttpUtils.HTTP_METHOD_POST, viewsToDisable, onRequestListener);
					break;

				case UPDATE:
					parameters.put("quantity", queryCart.getQuantity() + "");

					returnResult = execute(
							responseReceiverCheckErrors,
							DataConverter.Helper.build(ProductAdded.class, DataError.class, null),
							shouldUseCache,
							requestId,
							UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_update_delete_cart_entry,
									mUserInformation.getUserId(), mUserInformation.getCartId(), queryCart.getProduct()), parameters, null,
							true, HttpUtils.HTTP_METHOD_PUT, viewsToDisable, onRequestListener);
					break;

				case DELETE:
					returnResult = execute(
							responseReceiverCheckErrors,
							DataConverter.Helper.build(ProductAdded.class, DataError.class, null),
							shouldUseCache,
							requestId,
							UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_update_delete_cart_entry,
									mUserInformation.getUserId(), mUserInformation.getCartId(), queryCart.getProduct()), null, null, true,
							HttpUtils.HTTP_METHOD_DELETE, viewsToDisable, onRequestListener);
					break;

				default:
					break;
			}

			return returnResult;
		}

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#createCart(com.hybris.mobile.lib.http.response.ResponseReceiver
	 * , java.lang.String, boolean, java.util.List, com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean createCart(ResponseReceiver<Cart> responseReceiver, String requestId, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		return execute(responseReceiver, DataConverter.Helper.build(Cart.class, DataError.class, null), shouldUseCache, requestId,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_carts, mUserInformation.getUserId()), null, null, true,
				HttpUtils.HTTP_METHOD_POST, viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#getCart(com.hybris.mobile.lib.http.response.ResponseReceiver
	 * , java.lang.String, boolean, java.util.List, com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean getCart(final ResponseReceiver<Cart> responseReceiver, final String requestId, final boolean shouldUseCache,
			final List<View> viewsToDisable, final OnRequestListener onRequestListener)
	{

		// If a cart already exists for the user, we retrieve if
		if (StringUtils.isNotBlank(mUserInformation.getCartId()))
		{
			ResponseReceiver<Cart> responseReceiverGetCart = new ResponseReceiver<Cart>()
			{

				@Override
				public void onResponse(Response<Cart> response)
				{
					responseReceiver.onResponse(response);
				}

				@Override
				public void onError(Response<DataError> response)
				{
					// Error with the cart, we delete the reference and we re-call the method to get an updated cart
					mUserInformation.setCartId(null);

					// Re-calling the method to get an updated cart
					getCart(responseReceiver, requestId, shouldUseCache, viewsToDisable, onRequestListener);
				}
			};

			// Getting the cart saved on the user information
			return execute(
					responseReceiverGetCart,
					DataConverter.Helper.build(Cart.class, DataError.class, null),
					shouldUseCache,
					requestId,
					UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_cart, mUserInformation.getUserId(),
							mUserInformation.getCartId()), null, null, true, HttpUtils.HTTP_METHOD_GET, viewsToDisable,
					onRequestListener);
		}
		// No saved cart, we get the user's current cart if any of or we create a default one
		else
		{

			ResponseReceiver<Cart> responseReceiverGetCurrentCart = new ResponseReceiver<Cart>()
			{

				@Override
				public void onResponse(Response<Cart> response)
				{
					// Saving the cart information and re-calling the method to get the cart from the user information
					mUserInformation.setCartId(response.getData().getCode());
					getCart(responseReceiver, requestId, shouldUseCache, viewsToDisable, onRequestListener);
				}

				@Override
				public void onError(Response<DataError> response)
				{
					ResponseReceiver<Cart> responseReceiverCreateCart = new ResponseReceiver<Cart>()
					{

						@Override
						public void onResponse(Response<Cart> response)
						{
							// Saving the cart information and re-calling the method to get the cart from the user information
							mUserInformation.setCartId(response.getData().getCode());
							getCart(responseReceiver, requestId, shouldUseCache, viewsToDisable, onRequestListener);
						}

						@Override
						public void onError(Response<DataError> response)
						{
							responseReceiver.onError(response);
						}
					};

					createCart(responseReceiverCreateCart, requestId, shouldUseCache, viewsToDisable, onRequestListener);
				}
			};

			// We retrieve the user's current cart
			return getCurrentCart(responseReceiverGetCurrentCart, shouldUseCache);

		}
	}

	/**
	 * Get the user's current cart
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param shouldUseCache
	 *           Indicator to use cache or not
	 * @return
	 */
	private boolean getCurrentCart(ResponseReceiver<Cart> responseReceiver, boolean shouldUseCache)
	{
		return execute(responseReceiver, DataConverter.Helper.build(Cart.class, DataError.class, null), shouldUseCache, null,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_carts_current, mUserInformation.getUserId()), null, null,
				true, HttpUtils.HTTP_METHOD_GET, null, null);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#getDeliveryModes(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean getDeliveryModes(ResponseReceiver<List<DeliveryMode>> responseReceiver, String requestId,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		return executeForList(responseReceiver, DataConverter.Helper.build(DeliveryMode.class, DataError.class, "deliveryModes"),
				shouldUseCache, requestId, UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_delivery_modes,
						mUserInformation.getUserId(), mUserInformation.getCartId()), null, null, true, HttpUtils.HTTP_METHOD_GET,
				viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#updateCartDeliveryMode(com.hybris.mobile.lib.http.response
	 * .ResponseReceiver, java.lang.String, java.lang.String, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean updateCartDeliveryMode(ResponseReceiver<Cart> responseReceiver, String requestId, String deliveryMode,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener)
	{

		if (StringUtils.isBlank(deliveryMode))
		{
			throw new IllegalArgumentException();
		}

		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("deliveryModeId", deliveryMode);

		return execute(responseReceiver, DataConverter.Helper.build(Cart.class, DataError.class, null), shouldUseCache, requestId,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_cart_delivery_mode, mUserInformation.getUserId(),
						mUserInformation.getCartId()), parameters, null, true, HttpUtils.HTTP_METHOD_PUT, viewsToDisable,
				onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#getCostCenters(com.hybris.mobile.lib.http.response.
	 * ResponseReceiver, java.lang.String, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean getCostCenters(ResponseReceiver<List<CostCenter>> responseReceiver, String requestId, boolean shouldUseCache,
			List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		return executeForList(responseReceiver, DataConverter.Helper.build(CostCenter.class, DataError.class, "costCenters"),
				shouldUseCache, requestId, UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_cost_center), null, null, true,
				HttpUtils.HTTP_METHOD_GET, viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#updateCartCostCenter(com.hybris.mobile.lib.http.response
	 * .ResponseReceiver, java.lang.String, java.lang.String, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean updateCartCostCenter(ResponseReceiver<Cart> responseReceiver, String requestId, String costCenterId,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener)
	{

		if (StringUtils.isBlank(costCenterId))
		{
			throw new IllegalArgumentException();
		}

		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("costCenterId", costCenterId);

		return execute(responseReceiver, DataConverter.Helper.build(Cart.class, DataError.class, null), shouldUseCache, requestId,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_cart_cost_center, mUserInformation.getUserId(),
						mUserInformation.getCartId()), parameters, null, true, HttpUtils.HTTP_METHOD_PUT, viewsToDisable,
				onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#updateCartPaymentType(com.hybris.mobile.lib.http.response
	 * .ResponseReceiver, java.lang.String, java.lang.String, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean updateCartPaymentType(ResponseReceiver<Cart> responseReceiver, String requestId, String paymentType,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		if (StringUtils.isBlank(paymentType))
		{
			throw new IllegalArgumentException();
		}

		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("paymentType", paymentType);

		return execute(responseReceiver, DataConverter.Helper.build(Cart.class, DataError.class, null), shouldUseCache, requestId,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_cart_payment_type, mUserInformation.getUserId(),
						mUserInformation.getCartId()), parameters, null, true, HttpUtils.HTTP_METHOD_PUT, viewsToDisable,
				onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#updateCartDeliveryAddress(com.hybris.mobile.lib.http.response
	 * .ResponseReceiver, java.lang.String, java.lang.String, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean updateCartDeliveryAddress(ResponseReceiver<Cart> responseReceiver, String requestId, String addressId,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException
	{
		if (StringUtils.isBlank(addressId))
		{
			throw new IllegalArgumentException();
		}

		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("addressId", addressId);

		return execute(responseReceiver, DataConverter.Helper.build(Cart.class, DataError.class, null), shouldUseCache, requestId,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_cart_delivery_address, mUserInformation.getUserId(),
						mUserInformation.getCartId()), parameters, null, true, HttpUtils.HTTP_METHOD_PUT, viewsToDisable,
				onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#placeOrder(com.hybris.mobile.lib.http.response.ResponseReceiver
	 * , java.lang.String, boolean, java.util.List, com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean placeOrder(final ResponseReceiver<Order> responseReceiver, String requestId, QueryPlaceOrder queryPlaceOrder,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener) throws IllegalArgumentException
	{

		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("cartId", mUserInformation.getCartId());
		parameters.put("termsChecked", String.valueOf(queryPlaceOrder.isTermsChecked()));

		//  We want to remove the  current cart reference before sending back the result
		ResponseReceiver<Order> responseReceiverPlaceOrder = new ResponseReceiver<Order>()
		{

			@Override
			public void onResponse(Response<Order> response)
			{
				mUserInformation.setCartId(null);
				responseReceiver.onResponse(response);
			}

			@Override
			public void onError(Response<DataError> response)
			{
				responseReceiver.onError(response);
			}
		};

		return execute(responseReceiverPlaceOrder, DataConverter.Helper.build(Order.class, DataError.class, null), shouldUseCache,
				requestId, UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_place_order, mUserInformation.getUserId()),
				parameters, null, true, HttpUtils.HTTP_METHOD_POST, viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.hybris.mobile.lib.b2b.service.ContentServiceHelper#getOrder(com.hybris.mobile.lib.http.response.ResponseReceiver
	 * , java.lang.String, java.lang.String, boolean, java.util.List,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener)
	 */
	@Override
	public boolean getOrder(ResponseReceiver<Order> responseReceiver, String requestId, String orderNumber,
			boolean shouldUseCache, List<View> viewsToDisable, OnRequestListener onRequestListener)
	{

		if (StringUtils.isBlank(orderNumber))
		{
			throw new IllegalArgumentException();
		}

		return execute(responseReceiver, DataConverter.Helper.build(Order.class, DataError.class, null), shouldUseCache, requestId,
				UrlHelper.getWebserviceCatalogUrl(mContext, R.string.path_order_details, mUserInformation.getUserId(), orderNumber),
				null, null, true, HttpUtils.HTTP_METHOD_GET, viewsToDisable, onRequestListener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#loadImage(java.lang.String, java.lang.String,
	 * android.widget.ImageView, int, int, boolean, com.hybris.mobile.lib.http.listener.OnRequestListener, boolean)
	 */
	@Override
	public boolean loadImage(String url, String requestId, ImageView imageView, int width, int height, boolean shouldUseCache,
			OnRequestListener onRequestListener, boolean forceImageTagToMatchRequestId) throws IllegalArgumentException
	{

		if (StringUtils.isBlank(url) || imageView == null)
		{
			throw new IllegalArgumentException();
		}

		// We set the image tag if we want the request id to match the tag before loading the image within the image view
		if (forceImageTagToMatchRequestId)
		{
			imageView.setTag(requestId);
		}

		return mPersistenceHelper.setImageFromUrl(UrlHelper.getImageUrl(mContext, url), requestId, imageView, width, height,
				CONFIG_IMAGES_QUALITY, shouldUseCache, onRequestListener, forceImageTagToMatchRequestId);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#cancel(java.lang.String)
	 */
	@Override
	public void cancel(String requestId)
	{
		mPersistenceHelper.cancel(requestId);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#pause()
	 */
	@Override
	public void pause()
	{
		mPersistenceHelper.pause();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.service.ContentServiceHelper#start()
	 */
	@Override
	public void start()
	{
		mPersistenceHelper.start();
	}

	/**
	 * Execute the request for a generic T response
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param dataConverterHelper
	 *           Helper to convert the result into a POJO
	 * @param getCachedResult
	 *           Indicator to use cache or not
	 * @param requestId
	 *           Identifier for the call
	 * @param url
	 *           Url to call
	 * @param parameters
	 *           Call parameters
	 * @param headers
	 *           Call parameters headers
	 * @param isAuthorizedRequest
	 *           Flag for calls that need the user token
	 * @param httpMethod
	 *           Http method: GET, POST, PUT, DELETE
	 * @param viewsToDisable
	 *           List of views to disable/enable before/after the call
	 * @param onRequestListener
	 *           Request listener for before/after call actions
	 * @return
	 */
	private <T, Z> boolean execute(final ResponseCallback<T, Z> responseReceiver,
			final DataConverter.Helper<T, Z> dataConverterHelper, boolean getCachedResult, final String requestId, String url,
			Map<String, String> parameters, Map<String, String> headers, boolean isAuthorizedRequest, String httpMethod,
			List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		return executeRequest(responseReceiver, null, dataConverterHelper, getCachedResult, requestId, url, parameters, headers,
				isAuthorizedRequest, httpMethod, viewsToDisable, onRequestListener);
	}

	/**
	 * Execute the request for a generic List<T> response
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param dataConverterHelper
	 *           Helper to convert the result into a POJO
	 * @param getCachedResult
	 *           Indicator to use cache or not
	 * @param requestId
	 *           Identifier for the call
	 * @param url
	 *           Url to call
	 * @param parameters
	 *           Call parameters
	 * @param headers
	 *           Call parameters headers
	 * @param isAuthorizedRequest
	 *           Flag for calls that need the user token
	 * @param httpMethod
	 *           Http method: GET, POST, PUT, DELETE
	 * @param viewsToDisable
	 *           List of views to disable/enable before/after the call
	 * @param onRequestListener
	 *           Request listener for before/after call actions
	 * @return
	 */
	private <T, Z> boolean executeForList(final ResponseCallback<List<T>, Z> responseReceiver,
			final DataConverter.Helper<T, Z> dataConverterHelper, boolean getCachedResult, final String requestId, String url,
			Map<String, String> parameters, Map<String, String> headers, boolean isAuthorizedRequest, String httpMethod,
			List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		return executeRequest(null, responseReceiver, dataConverterHelper, getCachedResult, requestId, url, parameters, headers,
				isAuthorizedRequest, httpMethod, viewsToDisable, onRequestListener);
	}

	/**
	 * Execute a request
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param responseReceiverList
	 *           Response callback result (list case)
	 * @param dataConverterHelper
	 *           Helper to convert the result into a POJO
	 * @param getCachedResult
	 *           Indicator to use cache or not
	 * @param requestId
	 *           Identifier for the call
	 * @param url
	 *           Url to call
	 * @param parameters
	 *           Call parameters
	 * @param headers
	 *           Call parameters headers
	 * @param isAuthorizedRequest
	 *           Flag for calls that need the user token
	 * @param httpMethod
	 *           Http method: GET, POST, PUT, DELETE
	 * @param viewsToDisable
	 *           List of views to disable/enable before/after the call
	 * @param onRequestListener
	 *           Request listener for before/after call actions
	 * @return
	 */
	private <T, Z> boolean executeRequest(final ResponseCallback<T, Z> responseReceiver,
			final ResponseCallback<List<T>, Z> responseReceiverList, final DataConverter.Helper<T, Z> dataConverterHelper,
			final boolean getCachedResult, final String requestId, final String url, final Map<String, String> parameters,
			final Map<String, String> headers, final boolean isAuthorizedRequest, final String httpMethod,
			final List<View> viewsToDisable, final OnRequestListener onRequestListener)
	{
		boolean refreshTokenNeeded = false;
		final Map<String, String> finalHeader = new HashMap<String, String>();

		// We initialize the header Map
		if (headers != null)
		{
			finalHeader.putAll(headers);
		}

		// We pass the access token for authorized requests
		if (isAuthorizedRequest)
		{

			// The token is expired, we refresh it
			if (mUserInformation.isTokenExpired() || mUserInformation.isTokenInvalid())
			{

				refreshTokenNeeded = true;

				// No refresh token, we send a logout message
				if (StringUtils.isBlank(mUserInformation.getRefresh_token()))
				{
					Log.e(TAG, "Refresh token empty");
					sendLogoutBroadcast();
				}
				// We refresh the token
				else
				{
					refreshToken(new ResponseReceiver<UserInformation>()
					{

						@Override
						public void onResponse(Response<UserInformation> response)
						{

							// Getting the new token
							String savedUserId = mUserInformation.getUserId();
							String savedCartId = mUserInformation.getCartId();

							mUserInformation = response.getData();
							mUserInformation.setIssuedOn(Calendar.getInstance().getTimeInMillis());
							mUserInformation.setUserId(savedUserId);
							mUserInformation.setCartId(savedCartId);

							executeRequest(responseReceiver, responseReceiverList, dataConverterHelper, getCachedResult, requestId, url,
									parameters, finalHeader, isAuthorizedRequest, httpMethod, viewsToDisable, onRequestListener);
						}

						@Override
						public void onError(Response<DataError> response)
						{
							Log.e(TAG, "Error refreshing the user token. Details:" + response.getData());
							sendLogoutBroadcast();
						}
					}, mUserInformation.getRefresh_token());
				}
			}
			else
			{
				finalHeader.put(HEADER_AUTHORIZATION, HEADER_AUTHORIZATION_BEARER + " " + mUserInformation.getAccess_token());
			}

		}

		if (!refreshTokenNeeded)
		{

			// Before doing the request
			if (onRequestListener != null)
			{
				onRequestListener.beforeRequest();
			}

			// Disabling the views before the call
			if (viewsToDisable != null)
			{
				for (View view : viewsToDisable)
				{
					view.setEnabled(false);
					view.setActivated(false);
				}
			}

			// Generic T case
			if (responseReceiver != null)
			{
				ResponseCallback<T, Z> responseReceiverActionsBeforeCallback = new ResponseCallback<T, Z>()
				{

					@Override
					public void onResponse(Response<T> dataResponse)
					{
						afterRequestActions(responseReceiver, responseReceiverList, dataResponse, null, null, dataConverterHelper,
								getCachedResult, requestId, url, parameters, finalHeader, isAuthorizedRequest, httpMethod,
								viewsToDisable, onRequestListener);
					}

					@Override
					public void onError(Response<Z> response)
					{
						afterRequestActions(responseReceiver, responseReceiverList, null, null, response, dataConverterHelper,
								getCachedResult, requestId, url, parameters, finalHeader, isAuthorizedRequest, httpMethod,
								viewsToDisable, onRequestListener);
					}

				};

				return mPersistenceHelper.execute(responseReceiverActionsBeforeCallback, dataConverterHelper, getCachedResult,
						requestId, url, parameters, finalHeader, httpMethod);
			}
			// Generic List<T> case
			else
			{
				ResponseCallback<List<T>, Z> responseReceiverActionsBeforeCallback = new ResponseCallback<List<T>, Z>()
				{

					@Override
					public void onResponse(Response<List<T>> dataResponse)
					{
						afterRequestActions(responseReceiver, responseReceiverList, null, dataResponse, null, dataConverterHelper,
								getCachedResult, requestId, url, parameters, finalHeader, isAuthorizedRequest, httpMethod,
								viewsToDisable, onRequestListener);
					}

					@Override
					public void onError(Response<Z> response)
					{
						afterRequestActions(responseReceiver, responseReceiverList, null, null, response, dataConverterHelper,
								getCachedResult, requestId, url, parameters, finalHeader, isAuthorizedRequest, httpMethod,
								viewsToDisable, onRequestListener);
					}
				};

				return mPersistenceHelper.executeForList(responseReceiverActionsBeforeCallback, dataConverterHelper, getCachedResult,
						requestId, url, parameters, finalHeader, httpMethod);
			}

		}
		else
		{
			return false;
		}
	}

	/**
	 * Actions for after request
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param responseReceiverList
	 *           Response callback result (list case)
	 * @param dataResponse
	 *           The response to return
	 * @param dataResponseList
	 *           The response to return (list case)
	 * @param dataConverterHelper
	 *           Helper to convert the result into a POJO
	 * @param getCachedResult
	 *           Indicator to use cache or not
	 * @param requestId
	 *           Identifier for the call
	 * @param url
	 *           Url to call
	 * @param parameters
	 *           Call parameters
	 * @param headers
	 *           Call parameters headers
	 * @param isAuthorizedRequest
	 *           Flag for calls that need the user token
	 * @param httpMethod
	 *           Http method: GET, POST, PUT, DELETE
	 * @param viewsToDisable
	 *           List of views to disable/enable before/after the call
	 * @param onRequestListener
	 *           Request listener for before/after call actions
	 */
	private <T, Z> void afterRequestActions(final ResponseCallback<T, Z> responseReceiver,
			final ResponseCallback<List<T>, Z> responseReceiverList, Response<T> dataResponse, Response<List<T>> dataResponseList,
			Response<Z> dataResponseError, final DataConverter.Helper<T, Z> dataConverterHelper, final boolean getCachedResult,
			final String requestId, final String url, final Map<String, String> parameters, final Map<String, String> headers,
			final boolean isAuthorizedRequest, final String httpMethod, final List<View> viewsToDisable,
			final OnRequestListener onRequestListener)
	{
		boolean refreshTokenNeeded = false;

		// Checking if some error occured 
		if (dataResponseError != null && dataResponseError.getData() != null && dataResponseError.getData() instanceof DataError)
		{
			ErrorMessage error = ((DataError) dataResponseError.getData()).getErrorMessage();

			// Token not valid
			refreshTokenNeeded = error != null
					&& (StringUtils.equals(error.getType(), Constants.ERROR_TYPE_INVALIDTOKENERROR) || (StringUtils.equals(
							error.getType(), Constants.ERROR_TYPE_UNAUTHORIZEDERROR)));
		}

		// We need to refresh the token so we re-send the request by invalidating the token for the user
		if (refreshTokenNeeded)
		{
			mUserInformation.setTokenInvalid(true);
			executeRequest(responseReceiver, responseReceiverList, dataConverterHelper, getCachedResult, requestId, url, parameters,
					headers, isAuthorizedRequest, httpMethod, viewsToDisable, onRequestListener);
		}
		else
		{
			if (viewsToDisable != null)
			{
				for (View view : viewsToDisable)
				{
					view.setEnabled(true);
					view.setActivated(true);
				}
			}

			// After doing the request
			if (onRequestListener != null)
			{
				onRequestListener.afterRequest();
			}

			// Generic T case
			if (responseReceiver != null)
			{

				if (dataResponseError != null)
				{
					responseReceiver.onError(dataResponseError);
				}
				else
				{
					responseReceiver.onResponse(dataResponse);
				}

			}
			// Generic List<T> case
			else if (responseReceiverList != null)
			{
				if (dataResponseError != null)
				{
					responseReceiverList.onError(dataResponseError);
				}
				else
				{
					responseReceiverList.onResponse(dataResponseList);
				}
			}

		}
	}

}
