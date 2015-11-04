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

import android.os.Bundle;

import com.hybris.mobile.app.b2b.R;


/**
 * Show more information for a specific product from the product list
 * 
 */
public class ProductDetailActivity extends MainActivity
{

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		setContentView(R.layout.activity_product_detail);
		super.onCreate(savedInstanceState);
	}

}
