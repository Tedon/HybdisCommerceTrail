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
package com.hybris.mobile.lib.http;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;

import android.content.Context;
import android.graphics.Bitmap.Config;
import android.widget.ImageView;

import com.hybris.mobile.lib.http.converter.DataConverter;
import com.hybris.mobile.lib.http.converter.exception.DataConverterException;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.manager.PersistenceManager;
import com.hybris.mobile.lib.http.response.DataResponse;
import com.hybris.mobile.lib.http.response.DataResponseCallBack;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.http.response.ResponseCallback;
import com.hybris.mobile.lib.http.utils.ConnectionUtils;


/**
 * Helper to access the persistence manager
 * 
 */
public class PersistenceHelper
{

	public static final String TAG = PersistenceHelper.class.getCanonicalName();
	public final static int CACHE_EXPIRE_IN_DAYS = 360;
	private Context mContext;
	private PersistenceManager mPersistenceManager;
	private DataConverter mDataConverter;

	public PersistenceHelper(Context context, PersistenceManager persistenceManager, DataConverter dataConverter)
	{
		if (persistenceManager == null || context == null || dataConverter == null)
		{
			throw new IllegalArgumentException();
		}

		this.mPersistenceManager = persistenceManager;
		this.mDataConverter = dataConverter;
		this.mContext = context;
	}

	/**
	 * Execute a request for a URL
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param getCachedResult
	 *           Whether or not we should get the cached result first. Determine also if we cache the result from the
	 *           call.
	 * @param requestId
	 *           Identifier for the call
	 * @param url
	 *           Http Address to the WebService
	 * @param params
	 *           Map (name, value) of parameters to pass with the request
	 * @param headers
	 *           Map (name, value) of headers to pass with the request
	 * @param httpMethod
	 *           Method to use for the HTTP call
	 * @return true If no error in the process of executing this method. Note that this does not mean whether or not the
	 *         request was a success.
	 */
	public boolean executeRequest(DataResponseCallBack responseReceiver, boolean getCachedResult, final String requestId,
			String url, Map<String, String> params, Map<String, String> headers, String httpMethod)
	{

		boolean result = true;

		// 1 - If needed, return the un-sync response first
		if (isCacheResultRequest(getCachedResult))
		{
			// Getting the cache
			byte[] cacheResult = mPersistenceManager.getCache(url);

			if (cacheResult != null)
			{
				responseReceiver.onResponse(DataResponse.createSuccessResponse(new String(cacheResult), false));
			}
		}

		// 2 - If connected to the Internet, execute the call
		if (ConnectionUtils.isConnectedToInternet(this.mContext))
		{
			mPersistenceManager.getResponse(responseReceiver, requestId, httpMethod, url, params, headers, getCachedResult);
		}
		// Else create and return a no connection error message
		else
		{
			responseReceiver.onError(DataResponse.createErrorResponse(
					mDataConverter.createErrorMessage(mContext.getString(R.string.error_no_connection)), false));
		}

		return result;

	}

	/**
	 * Execute the request then convert the results into the generic T response
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param dataConverterHelper
	 *           Helper to convert the result into a POJO
	 * @param getCachedResult
	 *           Indicator to use cache or not * @param requestId Identifier for the call
	 * @param url
	 *           Url to call
	 * @param parameters
	 *           Call parameters
	 * @param headers
	 *           Call parameters headers
	 * @param httpMethod
	 *           Http method: GET, POST, PUT, DELETE
	 * 
	 * @return
	 */
	public <T, Z> boolean execute(final ResponseCallback<T, Z> responseReceiver,
			final DataConverter.Helper<T, Z> dataConverterHelper, boolean getCachedResult, final String requestId, String url,
			Map<String, String> parameters, Map<String, String> headers, String httpMethod)
	{

		DataResponseCallBack dataResponseCallBack = new DataResponseCallBack()
		{

			@Override
			public void onResponse(DataResponse dataResponse)
			{

				try
				{
					Response<T> response = null;

					// Conversion with the DataConverter
					if (StringUtils.isBlank(dataConverterHelper.getPropertyName()))
					{
						response = Response.createResponse(
								mDataConverter.convertFrom(dataConverterHelper.getClassName(), dataResponse.getData()), requestId,
								dataResponse.isSync());
					}
					else
					{
						response = Response.createResponse(mDataConverter.convertFrom(dataConverterHelper.getClassName(),
								dataResponse.getData(), dataConverterHelper.getPropertyName()), requestId, dataResponse.isSync());
					}
					responseReceiver.onResponse(response);
				}
				// Conversion error, we return the response with the error message
				catch (DataConverterException e)
				{
					try
					{
						responseReceiver.onError(Response.createResponse(
								mDataConverter.convertFrom(dataConverterHelper.getErrorClassName(),
										mDataConverter.createErrorMessage(dataResponse.getData())), requestId, dataResponse.isSync()));
					}
					catch (DataConverterException e1)
					{
						throw new IllegalArgumentException(e1.getLocalizedMessage());
					}
				}

			}

			@Override
			public void onError(DataResponse dataResponse)
			{
				try
				{
					responseReceiver.onError(Response.createResponse(
							mDataConverter.convertFrom(dataConverterHelper.getErrorClassName(), dataResponse.getData()), requestId,
							dataResponse.isSync()));
				}
				// Conversion error, we return the response with the error message
				catch (DataConverterException e)
				{

					String errorMsg = dataResponse.getData();

					// Unknown error if no message coming from the http layer
					if (StringUtils.isBlank(errorMsg))
					{
						errorMsg = mContext.getString(R.string.error_unknown);
					}

					try
					{
						responseReceiver.onError(Response.createResponse(
								mDataConverter.convertFrom(dataConverterHelper.getErrorClassName(),
										mDataConverter.createErrorMessage(dataResponse.getData())), requestId, dataResponse.isSync()));
					}
					catch (DataConverterException e1)
					{
						throw new IllegalArgumentException(e1.getLocalizedMessage());
					}
				}

			}
		};

		return executeRequest(dataResponseCallBack, getCachedResult, requestId, url, parameters, headers, httpMethod);

	}

	/**
	 * Execute the request then convert the results into the generic List<T> response
	 * 
	 * @param responseReceiver
	 *           Response callback result
	 * @param dataConverterHelper
	 *           Helper to convert the result into a POJO
	 * @param getCachedResult
	 *           Indicator to use cache or not * @param requestId Identifier for the call
	 * @param url
	 *           Url to call
	 * @param parameters
	 *           Call parameters
	 * @param headers
	 *           Call parameters headers
	 * @param httpMethod
	 *           Http method: GET, POST, PUT, DELETE
	 * @return
	 */
	public <T, Z> boolean executeForList(final ResponseCallback<List<T>, Z> responseReceiver,
			final DataConverter.Helper<T, Z> dataConverterHelper, boolean getCachedResult, final String requestId, String url,
			Map<String, String> params, Map<String, String> headers, String httpMethod)
	{

		DataResponseCallBack dataResponseCallBack = new DataResponseCallBack()
		{

			@Override
			public void onResponse(DataResponse dataResponse)
			{
				try
				{

					Response<List<T>> response = null;

					// Conversion with the DataConverter
					if (StringUtils.isBlank(dataConverterHelper.getPropertyName()))
					{
						response = Response.createResponse(
								mDataConverter.convertFromList(dataConverterHelper.getClassName(), dataResponse.getData()), requestId,
								dataResponse.isSync());
					}
					else
					{
						response = Response.createResponse(mDataConverter.convertFromList(dataConverterHelper.getClassName(),
								dataResponse.getData(), dataConverterHelper.getPropertyName()), requestId, dataResponse.isSync());
					}

					responseReceiver.onResponse(response);

				}
				// Conversion error, we return the response with the error message
				catch (DataConverterException e)
				{
					try
					{
						responseReceiver.onError(Response.createResponse(
								mDataConverter.convertFrom(dataConverterHelper.getErrorClassName(),
										mDataConverter.createErrorMessage(dataResponse.getData())), requestId, dataResponse.isSync()));
					}
					catch (DataConverterException e1)
					{
						throw new IllegalArgumentException(e1.getLocalizedMessage());
					}
				}

			}

			@Override
			public void onError(DataResponse dataResponse)
			{
				try
				{
					responseReceiver.onError(Response.createResponse(
							mDataConverter.convertFrom(dataConverterHelper.getErrorClassName(), dataResponse.getData()), requestId,
							dataResponse.isSync()));
				}
				// Conversion error, we return the response with the error message
				catch (DataConverterException e)
				{
					try
					{
						responseReceiver.onError(Response.createResponse(
								mDataConverter.convertFrom(dataConverterHelper.getErrorClassName(),
										mDataConverter.createErrorMessage(dataResponse.getData())), requestId, dataResponse.isSync()));
					}
					catch (DataConverterException e1)
					{
						throw new IllegalArgumentException(e1.getLocalizedMessage());
					}
				}
			}
		};

		return executeRequest(dataResponseCallBack, getCachedResult, requestId, url, params, headers, httpMethod);

	}

	/**
	 * Get and set the image from the url to the imageView
	 * 
	 * @param url
	 *           Http Address for Image
	 * @param requestId
	 *           Identifier for the call
	 * @param imageView
	 *           ImageView to be updated
	 * @param width
	 *           Horizontal size in pixels (or 0 for automatic)
	 * @param height
	 *           Vertical size in pixels (or 0 for automatic)
	 * @param config
	 *           Bitmap configurations to apply on the image
	 * @param getCachedResult
	 *           Whether or not we should set the image with the cached result first. Determine also if we cache the
	 *           image from the call.
	 * @param onRequestListener
	 *           Its methods will be called when the request is sent
	 * @param forceImageTagToMatchRequestId
	 *           If set to true, the imageView will set its tag with the requestId value and will verify after getting
	 *           the image content from the url, that the tag is still equals to the requestId. If yes, the imageView is
	 *           updated with the content just pulled.
	 * @return
	 */
	public boolean setImageFromUrl(String url, String requestId, ImageView imageView, int width, int height, Config config,
			boolean getCachedResult, OnRequestListener onRequestListener, boolean forceImageTagToMatchRequestId)
	{
		mPersistenceManager.setImageFromUrl(url, requestId, imageView, width, height, config, getCachedResult, onRequestListener,
				forceImageTagToMatchRequestId);

		return true;
	}

	/**
	 * Return true if we want to get the cached result (explicit) or if the device is not connected to the Internet
	 * (implicit)
	 * 
	 * @param getCachedResult
	 * @return
	 */
	private boolean isCacheResultRequest(boolean getCachedResult)
	{
		return getCachedResult || !ConnectionUtils.isConnectedToInternet(this.mContext);
	}

	/**
	 * Cancel all the request associated with the id
	 * 
	 * @param requestId
	 *           Identifier for the call
	 */
	public void cancel(String requestId)
	{
		mPersistenceManager.cancel(requestId);
	}

	/**
	 * Pause any current work
	 */
	public void pause()
	{
		mPersistenceManager.pause();
	}

	/**
	 * Start or restart any pending work
	 */
	public void start()
	{
		mPersistenceManager.start();
	}

}
