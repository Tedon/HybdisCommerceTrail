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
 * Generic data response object
 * 
 * @param <T>
 */
public class Response<T>
{

	private boolean sync;
	private T data;
	private String requestId;

	private Response(T data, String requestId, boolean sync)
	{
		this.sync = sync;
		this.data = data;
		this.requestId = requestId;
	}

	public static <T> Response<T> createResponse(T data, String requestId, boolean sync)
	{
		return new Response<T>(data, requestId, sync);
	}

	public boolean isSync()
	{
		return sync;
	}

	public T getData()
	{
		return data;
	}

	public String getRequestId()
	{
		return requestId;
	}

}
