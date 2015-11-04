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
package com.hybris.mobile.lib.http.utils;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.lang3.StringUtils;

import android.util.Log;


/**
 * Utilities for http related
 * 
 */
public class HttpUtils
{
	private static final String TAG = HttpUtils.class.getCanonicalName();

	public final static String HTTP_METHOD_GET = "GET";
	public final static String HTTP_METHOD_POST = "POST";
	public final static String HTTP_METHOD_PUT = "PUT";
	public final static String HTTP_METHOD_DELETE = "DELETE";

	public final static String ENCODING_UTF8 = "UTF-8";

	public final static String URL_AMPERSTAND = "&";
	public final static String URL_PARAMETERS_EQUALS = "=";
	public final static String URL_QUESTION_MARK = "?";

	public final static String CONTENT_TYPE_URLENC = "application/x-www-form-urlencoded; charset=utf-8";

	private HttpUtils()
	{
	}

	/**
	 * Construct the parameters for a URL based on a Map of parameters
	 * 
	 * @param parameters
	 * @return
	 */
	public static String parametersToUrl(Map<String, String> parameters)
	{
		if (parameters != null)
		{

			StringBuilder sb = new StringBuilder();

			for (Entry<String, String> entry : parameters.entrySet())
			{
				if (StringUtils.isNotBlank(entry.getValue()))
				{

					try
					{
						sb.append(URLEncoder.encode(entry.getKey(), ENCODING_UTF8));
						sb.append(URL_PARAMETERS_EQUALS);
						sb.append(URLEncoder.encode(entry.getValue(), ENCODING_UTF8));
					}
					catch (UnsupportedEncodingException e)
					{
						Log.e(TAG, "Error encoding parameters in " + ENCODING_UTF8 + ". Details: " + e.getLocalizedMessage());
					}

					sb.append(URL_AMPERSTAND);

				}
			}

			return sb.toString();
		}
		else
		{
			return "";
		}
	}
}
