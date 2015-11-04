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

import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.activity.LoginActivity;
import com.hybris.mobile.app.b2b.fragment.CartFragment;
import com.hybris.mobile.app.b2b.utils.UIUtils;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.cart.Cart;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.ui.view.Alert;


/**
 * Helper for session related
 */
public final class SessionHelper
{

	public static final String LAST_LOGGED_IN_EMAIL = "LAST_LOGGED_IN_EMAIL";
	public static final String IS_USER_LOGGED_IN = "IS_USER_LOGGED_IN";
	public static final String CART_TOTAL_UNIT_COUNT = "CART_TOTAL_UNIT_COUNT";
	public static final String CART_TOTAL_UNIT_COUNT_PREVIOUS = "CART_TOTAL_UNIT_COUNT_PREVIOUS";
	public static final String CATALOG_PRODUCT_ITEM_VIEW_TYPE = "CATALOG_PRODUCT_ITEM_VIEW_TYPE";

	/**
	 * Save the last logged email
	 * 
	 * @param email
	 */
	public static void saveLastLoggedEmail(String email)
	{
		B2BApplication.setStringToSharedPreferences(LAST_LOGGED_IN_EMAIL, email);
	}

	/**
	 * Get the last logged email
	 */
	public static String getLastLoggedEmail()
	{
		return B2BApplication.getStringFromSharedPreferences(LAST_LOGGED_IN_EMAIL, "");
	}

	/**
	 * Return true if a user is logged in
	 * 
	 * @return
	 */
	public static boolean isUserLoggedIn()
	{
		return B2BApplication.getBooleanFromSharedPreferences(IS_USER_LOGGED_IN, false);
	}

	/**
	 * Set the user logged in hint to true
	 */
	public static void setUserLoggedIn()
	{
		B2BApplication.setBooleanToSharedPreferences(IS_USER_LOGGED_IN, true);
	}

	/**
	 * Logout a user
	 * 
	 * @param context
	 */
	public static void logout(Context context)
	{
		// Logout the user from the B2B layer
		B2BApplication.getContentServiceHelper().logout();

		// Clear logged in hint
		B2BApplication.setBooleanToSharedPreferences(IS_USER_LOGGED_IN, false);

		// Reset cart
		resetCart();

		// Redirect to the sign in page and remove back stack
		Intent logoutIntent = new Intent(context, LoginActivity.class);
		logoutIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		context.startActivity(logoutIntent);
	}

	/**
	 * Get the total unit count from the current cart from the shared preferences
	 * 
	 * @return
	 */
	public static int getCartTotalUnitCount()
	{
		return B2BApplication.getIntFromSharedPreferences(CART_TOTAL_UNIT_COUNT, 0);
	}

	/**
	 * Get the previous total unit count from the current cart from the shared preferences
	 * 
	 * @return
	 */
	public static int getCartTotalUnitCountPrevious()
	{
		return B2BApplication.getIntFromSharedPreferences(CART_TOTAL_UNIT_COUNT_PREVIOUS, 0);
	}

	/**
	 * Sync the unit count in the shared preferences between the previous value and current value
	 */
	public static void syncCartTotalUnitCountPrevious()
	{
		B2BApplication.setIntToSharedPreferences(CART_TOTAL_UNIT_COUNT_PREVIOUS, getCartTotalUnitCount());
	}

	/**
	 * Reset the previous total unit count
	 */
	public static void resetCartTotalUnitCountPrevious()
	{
		B2BApplication.setIntToSharedPreferences(CART_TOTAL_UNIT_COUNT_PREVIOUS, 0);
	}

	/**
	 * Reset the cart
	 */
	public static void resetCart()
	{
		resetCartTotalUnitCountPrevious();
		B2BApplication.setIntToSharedPreferences(CART_TOTAL_UNIT_COUNT, 0);
	}

	/**
	 * Update the cart from the content service helper and update the cart fragment
	 * 
	 * @param activity
	 *           The activity that calls the method
	 * @param requestId
	 *           Identifier for the call
	 * @param updateSummary
	 *           Flag if we want to populate the cart summary if the cart fragment is present
	 */
	public static void updateCart(final Activity activity, String requestId, final boolean updateSummary)
	{

		B2BApplication.getContentServiceHelper().getCart(new ResponseReceiver<Cart>()
		{
			@Override
			public void onResponse(Response<Cart> response)
			{

				updateCartItemCount(response.getData().getTotalUnitCount(), activity);

				// Updating the cart fragment
				Fragment cartFragment = activity.getFragmentManager().findFragmentById(R.id.cart_fragment);

				if (cartFragment != null && cartFragment instanceof CartFragment)
				{
					if (updateSummary)
					{
						((CartFragment) cartFragment).populateCartSummary(response.getData());
					}

					((CartFragment) cartFragment).populateCartContent(response.getData());
				}
			}

			@Override
			public void onError(Response<DataError> response)
			{
				Alert.showCritical(activity, response.getData().getErrorMessage().getMessage());
				updateCartItemCount(0, activity);
			}
		}, requestId, false, null, new OnRequestListener()
		{

			@Override
			public void beforeRequest()
			{
				UIUtils.showLoadingActionBar(activity, true);
			}

			@Override
			public void afterRequest()
			{
				UIUtils.showLoadingActionBar(activity, false);
			}
		});

	}

	/**
	 * Update the number of items in the shared preferences, and update the cart icon accordingly
	 * 
	 * @param nbItems
	 * @param activity
	 */
	public static void updateCartItemCount(int nbItems, Activity activity)
	{
		if (getCartTotalUnitCount() != nbItems)
		{
			B2BApplication.setIntToSharedPreferences(CART_TOTAL_UNIT_COUNT_PREVIOUS, getCartTotalUnitCount());
			B2BApplication.setIntToSharedPreferences(CART_TOTAL_UNIT_COUNT, nbItems);

			if (activity != null)
			{
				activity.invalidateOptionsMenu();
			}
		}
	}

	/**
	 * Get the view type saved for the catalog content page
	 * 
	 * @return
	 */
	public static int getCatalogContentViewType()
	{
		return B2BApplication.getIntFromSharedPreferences(CATALOG_PRODUCT_ITEM_VIEW_TYPE, 0);
	}

	/**
	 * Save the view type for the catalog content page
	 * 
	 * @return
	 */
	public static void setCatalogContentViewType(int index)
	{
		B2BApplication.setIntToSharedPreferences(CATALOG_PRODUCT_ITEM_VIEW_TYPE, index);
	}

}
