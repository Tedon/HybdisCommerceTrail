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
package com.hybris.mobile.app.b2b.activity;

import android.app.Fragment;
import android.os.Bundle;

import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.fragment.CartFragment.OnCartLoadedListener;
import com.hybris.mobile.app.b2b.fragment.CheckoutFragment;
import com.hybris.mobile.lib.b2b.data.cart.Cart;


/**
 * Checkout
 * 
 */
public class CheckoutActivity extends MainActivity implements OnCartLoadedListener
{
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		setContentView(R.layout.activity_checkout);
		super.onCreate(savedInstanceState);
	}

	@Override
	public void onCartLoaded(Cart cart)
	{
		Fragment fragment = getFragmentManager().findFragmentById(R.id.checkout_fragment);

		if (fragment != null && fragment instanceof CheckoutFragment)
		{
			((CheckoutFragment) fragment).beginCheckOutFlow();
		}
	}

	@Override
	public void onCartSummaryLoaded(Cart cart)
	{
		Fragment fragment = getFragmentManager().findFragmentById(R.id.checkout_fragment);

		if (fragment != null && fragment instanceof CheckoutFragment)
		{
			((CheckoutFragment) fragment).populateCartSummary(cart);
		}
	}
}
