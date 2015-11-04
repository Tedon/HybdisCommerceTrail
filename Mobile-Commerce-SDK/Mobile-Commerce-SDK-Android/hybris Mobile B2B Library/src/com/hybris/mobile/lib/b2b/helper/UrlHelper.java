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
package com.hybris.mobile.lib.b2b.helper;

import android.content.Context;

import com.hybris.mobile.lib.b2b.R;


/**
 * Helper for url operations
 */
public class UrlHelper
{

	/**
	 * Return the webservice Http Address that take into account the catalog + the method path to call
	 * 
	 * @param context
	 *           Application Context
	 * @param pathUrlStringResource
	 *           Webservice path
	 * @param formatArgs
	 *           Values to replace on the final returned String
	 * @return Formatted String Url for WebService
	 */
	public static String getWebserviceCatalogUrl(Context context, int pathUrlStringResource, Object... formatArgs)
	{
		return buildWebserviceUrl(context, true, pathUrlStringResource, formatArgs);
	}

	/**
	 * Return the webservice Http Address + the method path to call
	 * 
	 * @param context
	 *           Application Context
	 * @param pathUrlStringResource
	 *           Webservice path
	 * @param formatArgs
	 *           Values to replace on the final returned String
	 * @return Formatted String Url for WebService
	 */
	public static String getWebserviceUrl(Context context, int pathUrlStringResource, Object... formatArgs)
	{
		return buildWebserviceUrl(context, false, pathUrlStringResource, formatArgs);
	}

	/**
	 * Build the webservice Http Address
	 * 
	 * @param context
	 *           Application Context
	 * @param hasCatalog
	 *           Whether or not to add the catalog path
	 * @param pathUrlStringResource
	 *           Webservice path
	 * @param formatArgs
	 *           Values to replace on the final returned String
	 * @return Formatted String Url for WebService
	 */
	private static String buildWebserviceUrl(Context context, boolean hasCatalog, int pathUrlStringResource, Object... formatArgs)
	{
		String url = context.getString(R.string.url_backend) + context.getString(R.string.path_webservice);

		if (hasCatalog)
		{
			url += context.getString(R.string.path_webservice_catalog);
		}

		if (formatArgs != null && formatArgs.length > 0)
		{
			return url + context.getString(pathUrlStringResource, formatArgs);
		}
		else
		{
			return url + context.getString(pathUrlStringResource);
		}
	}

	/**
	 * Return the image Http Address
	 * 
	 * @param context
	 *           Application Context
	 * @param pathUrl
	 *           Url path of the image
	 * @return Formatted String Url for Image
	 */
	public static String getImageUrl(Context context, String pathUrl)
	{
		return context.getString(R.string.url_backend) + pathUrl;
	}
}
