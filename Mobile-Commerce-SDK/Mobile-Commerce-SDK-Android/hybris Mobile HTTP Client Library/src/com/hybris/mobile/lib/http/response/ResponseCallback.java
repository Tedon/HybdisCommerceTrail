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
package com.hybris.mobile.lib.http.response;

/**
 * Interface for receiving a Response callback result
 * 
 * @param <T>
 * @param <Z>
 */
public interface ResponseCallback<T, Z>
{
	/**
	 * Success response
	 * 
	 * @param response
	 */
	public void onResponse(Response<T> response);

	/**
	 * Error response
	 * 
	 * @param response
	 */
	public void onError(Response<Z> response);
}
