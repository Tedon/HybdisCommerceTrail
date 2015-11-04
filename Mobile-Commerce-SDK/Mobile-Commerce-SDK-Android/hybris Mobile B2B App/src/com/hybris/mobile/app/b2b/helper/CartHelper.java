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
package com.hybris.mobile.app.b2b.helper;

import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.app.Activity;
import android.view.View;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.utils.UIUtils;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.cart.ProductAdded;
import com.hybris.mobile.lib.b2b.query.QueryCart;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.ui.view.Alert;


/**
 * Helper for carts
 */
public class CartHelper
{

	public interface OnAddToCart
	{
		public void onAddToCart(ProductAdded productAdded);

		public void onAddToCartError(boolean isOutOfStock);
	}

	/**
	 * Update an item to the cart
	 * 
	 * @param activity
	 *           The activity that calls the method
	 * @param requestId
	 *           Identifier for the call
	 * @param onAddToCart
	 *           Listener for success/error after update
	 * @param entryNumber
	 *           The entry number to update on the cart
	 * @param quantity
	 *           The new quantity for the entry number
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Request listener for before/after call actions
	 */
	public static void updateCart(Activity activity, String requestId, OnAddToCart onAddToCart, int entryNumber, int quantity,
			List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		addOrUpdateToCart(activity, requestId, onAddToCart, true, null, entryNumber, quantity, viewsToDisable, onRequestListener);
	}

	/**
	 * Add an item to the cart
	 * 
	 * @param activity
	 *           The activity that calls the method
	 * @param requestId
	 *           Identifier for the call
	 * @param onAddToCart
	 *           Listener for success/error after update
	 * @param productCode
	 *           The code of the product to add
	 * @param quantity
	 *           The quantity to add
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Request listener for before/after call actions
	 */
	public static void addToCart(Activity activity, String requestId, OnAddToCart onAddToCart, String productCode, int quantity,
			List<View> viewsToDisable, OnRequestListener onRequestListener)
	{
		addOrUpdateToCart(activity, requestId, onAddToCart, false, productCode, 0, quantity, viewsToDisable, onRequestListener);
	}

	/**
	 * Add/Update an item to the cart.
	 * 
	 * @param activity
	 *           The activity that calls the method
	 * @param requestId
	 *           Identifier for the call
	 * @param onAddToCart
	 *           Listener for success/error after update
	 * @param isUpdate
	 *           Flag for update
	 * @param productCode
	 *           The code of the product to add
	 * @param entryNumber
	 *           The entry number to update on the cart
	 * @param quantity
	 *           The quantity to add
	 * @param viewsToDisable
	 *           Views to disable/enable before/after the request
	 * @param onRequestListener
	 *           Request listener for before/after call actions
	 */
	private static void addOrUpdateToCart(final Activity activity, final String requestId, final OnAddToCart onAddToCart,
			final boolean isUpdate, final String productCode, final int entryNumber, final int quantity,
			final List<View> viewsToDisable, final OnRequestListener onRequestListener)
	{

		if (quantity > 0)
		{
			UIUtils.showLoadingActionBar(activity, true);

			QueryCart queryCart = new QueryCart();
			queryCart.setQuantity(quantity);

			// Update
			if (isUpdate)
			{
				queryCart.setProduct(entryNumber + "");

				B2BApplication.getContentServiceHelper().updateCartEntry(new ResponseReceiver<ProductAdded>()
				{
					@Override
					public void onResponse(Response<ProductAdded> response)
					{
						onReceiveAddToCartResponse(activity, requestId, onAddToCart, response);
					}

					@Override
					public void onError(Response<DataError> response)
					{
						UIUtils.showLoadingActionBar(activity, false);
						Alert.showCritical(activity, response.getData().getErrorMessage().getMessage());

						// Update the cart
						SessionHelper.updateCart(activity, requestId, false);
					}
				}, requestId, queryCart, false, viewsToDisable, onRequestListener);
			}
			// Add
			else
			{
				queryCart.setProduct(productCode);

				B2BApplication.getContentServiceHelper().addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{
						onReceiveAddToCartResponse(activity, requestId, onAddToCart, response);
					}

					@Override
					public void onError(Response<DataError> response)
					{
						UIUtils.showLoadingActionBar(activity, false);
						Alert.showCritical(activity, response.getData().getErrorMessage().getMessage());

						// Update the cart
						SessionHelper.updateCart(activity, requestId, false);
					}
				}, requestId, queryCart, false, viewsToDisable, onRequestListener);
			}

		}
	}

	/**
	 * Called after adding/updating an item to the cart
	 * 
	 * @param activity
	 *           The activity that calls the method
	 * @param requestId
	 *           Identifier for the call
	 * @param onAddToCart
	 *           Listener for success/error after update
	 * @param response
	 *           Response data
	 */
	private static void onReceiveAddToCartResponse(Activity activity, final String requestId, OnAddToCart onAddToCart,
			Response<ProductAdded> response)
	{
		UIUtils.showLoadingActionBar(activity, false);

		// Out of stock, we print an error
		if (response.getData().isOutOfStock())
		{
			if (StringUtils.isNotBlank(response.getData().getStatusMessage()))
			{
				Alert.showError(activity, response.getData().getStatusMessage());
			}

			if (onAddToCart != null)
			{
				onAddToCart.onAddToCartError(true);
			}
		}
		// Quantity not fulfilled, we print a warning
		else if (response.getData().isQuantityAddedNotFulfilled())
		{
			if (StringUtils.isNotBlank(response.getData().getStatusMessage()))
			{
				Alert.showWarning(activity, response.getData().getStatusMessage());
			}

			if (onAddToCart != null)
			{
				onAddToCart.onAddToCartError(false);
			}
		}
		// Otherwise success message
		else
		{
			Alert.showSuccess(activity, activity.getString(R.string.cart_update_item_confirm_message));
		}

		if (onAddToCart != null)
		{
			onAddToCart.onAddToCart(response.getData());
		}

		// Update the cart
		SessionHelper.updateCart(activity, requestId, false);

	}
}
