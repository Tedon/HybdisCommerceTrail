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
package com.hybris.mobile.app.b2b;

import android.content.Context;


/**
 * Settings that will be used in the Application
 */
public class Configuration
{
	private Context mContext;

	private Configuration(Context context)
	{
		this.mContext = context;
	}

	/**
	 * Build the configuration
	 * 
	 * @param context
	 * @param persistenceManager
	 * @return
	 */
	public static Configuration buildConfiguration(Context context)
	{
		return new Configuration(context);
	}

	/**
	 * Return the default pagesize for list
	 * 
	 * @return
	 */
	public int getDefaultPageSize()
	{
		return mContext.getResources().getInteger(R.integer.pagesize);
	}

	/**
	 * Return the HockeyApp identifier
	 * 
	 * @return
	 */
	public String getHockeyAppIdentifier()
	{
		return mContext.getString(R.string.hockeyapp_app_id);
	}

}
