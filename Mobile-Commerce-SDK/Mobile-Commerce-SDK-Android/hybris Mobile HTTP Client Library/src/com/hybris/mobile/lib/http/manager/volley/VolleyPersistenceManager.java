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
package com.hybris.mobile.lib.http.manager.volley;

import java.io.UnsupportedEncodingException;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.impl.cookie.DateParseException;
import org.apache.http.impl.cookie.DateUtils;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.graphics.Bitmap.Config;
import android.util.Log;
import android.widget.ImageView;

import com.android.volley.AuthFailureError;
import com.android.volley.Cache;
import com.android.volley.NetworkResponse;
import com.android.volley.ParseError;
import com.android.volley.Request;
import com.android.volley.Request.Method;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.ImageLoader.ImageContainer;
import com.android.volley.toolbox.ImageLoader.ImageListener;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.hybris.mobile.lib.http.PersistenceHelper;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.manager.PersistenceManager;
import com.hybris.mobile.lib.http.response.DataResponse;
import com.hybris.mobile.lib.http.response.DataResponseCallBack;
import com.hybris.mobile.lib.http.utils.HttpUtils;


/**
 * Persistence manager implementation based on Volley library
 * (https://android.googlesource.com/platform/frameworks/volley/)
 * 
 */
public class VolleyPersistenceManager implements PersistenceManager
{

	private static final String TAG = VolleyPersistenceManager.class.getCanonicalName();
	private static final String HEADER_DATE = "Date";
	private static final String HEADER_ETAG = "ETag";
	private RequestQueue mQueue;
	private ImageLoader mImageLoader;

	/**
	 * TODO - Static block code allowing all SSL connections. Should be changed based on customer's needs.
	 */
	static
	{
		try
		{

			// Default cookie manager
			CookieManager cookieManager = new CookieManager();
			CookieHandler.setDefault(cookieManager);

			// Trust all SSL certificates
			TrustManager[] trustAllCerts = new TrustManager[]
			{ new X509TrustManager()
			{
				public X509Certificate[] getAcceptedIssuers()
				{
					X509Certificate[] myTrustedAnchors = new X509Certificate[0];
					return myTrustedAnchors;
				}

				@Override
				public void checkClientTrusted(X509Certificate[] certs, String authType)
				{
				}

				@Override
				public void checkServerTrusted(X509Certificate[] certs, String authType)
				{
				}
			} };

			SSLContext sc = SSLContext.getInstance("SSL");
			sc.init(null, trustAllCerts, new SecureRandom());
			HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
			HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier()
			{
				@Override
				public boolean verify(String arg0, SSLSession arg1)
				{
					return true;
				}
			});
		}
		catch (Exception e)
		{
			Log.e(TAG, "Error with the VolleyPersistenceManager initialization. Details: " + e.getLocalizedMessage());
			throw new IllegalStateException();
		}

	}

	public VolleyPersistenceManager(Context applicationContext)
	{
		this.mQueue = Volley.newRequestQueue(applicationContext);
		this.mImageLoader = new ImageLoader(this.mQueue, new BitmapCache());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#getResponse(com.hybris.mobile.lib.http.response.
	 * DataResponseCallBack, java.lang.String, java.lang.String, java.lang.String, java.util.Map, java.util.Map, boolean)
	 */
	@Override
	public void getResponse(final DataResponseCallBack dataResponseCallBack, final String requestId, String method, String url,
			final Map<String, String> parameters, final Map<String, String> headers, boolean shouldCache)
	{

		int intMethod = 0;

		if (StringUtils.equals(method, HttpUtils.HTTP_METHOD_GET))
		{
			intMethod = Method.GET;
		}
		else if (StringUtils.equals(method, HttpUtils.HTTP_METHOD_POST))
		{
			intMethod = Method.POST;
		}
		else if (StringUtils.equals(method, HttpUtils.HTTP_METHOD_PUT))
		{
			intMethod = Method.PUT;
		}
		else if (StringUtils.equals(method, HttpUtils.HTTP_METHOD_DELETE))
		{
			intMethod = Method.DELETE;
		}

		// Adding the request to the queue
		addToQueue(buildJsonObjectRequest(dataResponseCallBack, requestId, intMethod, url, parameters, headers), requestId,
				shouldCache);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#setImageFromUrl(java.lang.String, java.lang.String,
	 * android.widget.ImageView, int, int, android.graphics.Bitmap.Config, boolean,
	 * com.hybris.mobile.lib.http.listener.OnRequestListener, boolean)
	 */
	@Override
	public void setImageFromUrl(final String url, final String requestId, final ImageView imageView, int width, int height,
			Config config, boolean shouldCache, final OnRequestListener onRequestListener,
			final boolean forceImageTagToMatchRequestId)
	{

		if (onRequestListener != null)
		{
			onRequestListener.beforeRequest();
		}

		mImageLoader.get(url, new ImageListener()
		{

			@Override
			public void onErrorResponse(VolleyError error)
			{
				Log.e(TAG, "Error loading the image for url \"" + url + "\". " + error.getLocalizedMessage());

				if (onRequestListener != null)
				{
					onRequestListener.afterRequest();
				}
			}

			@Override
			public void onResponse(ImageContainer response, boolean arg1)
			{
				if (response.getBitmap() != null && imageView != null)
				{
					boolean loadImage = true;

					if (forceImageTagToMatchRequestId && imageView.getTag() != null
							&& !StringUtils.equals(requestId, imageView.getTag().toString()))
					{
						loadImage = false;
					}

					if (loadImage)
					{
						imageView.setImageBitmap(response.getBitmap());
					}

					if (onRequestListener != null)
					{
						onRequestListener.afterRequest();
					}
				}
			}
		});

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#getCache(java.lang.String)
	 */
	@Override
	public byte[] getCache(String url)
	{
		if (mQueue.getCache() != null && mQueue.getCache().get(url) != null)
		{

			// Get the cache
			byte[] responseBytes = mQueue.getCache().get(url).data;

			// Invalidate the cache
			mQueue.getCache().invalidate(url, true);

			return responseBytes;
		}

		return new byte[0];
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#removeCache(java.lang.String)
	 */
	@Override
	public void removeCache(String url)
	{
		if (mQueue.getCache() != null && mQueue.getCache().get(url) != null)
		{
			// Invalidate the cache
			mQueue.getCache().remove(url);
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#removeAllCache()
	 */
	@Override
	public void removeAllCache()
	{
		if (mQueue.getCache() != null)
		{
			mQueue.getCache().clear();
		}
	}

	/**
	 * Add a request object to the Volley queue and set the cache parameter
	 * 
	 * @param request
	 * @param requestId
	 * @param shouldCache
	 */
	private void addToQueue(Request<?> request, String requestId, boolean shouldCache)
	{
		// Cache or not
		request.setShouldCache(shouldCache);

		// Tag
		if (requestId != null)
		{
			request.setTag(requestId);
		}

		mQueue.add(request);
	}

	/**
	 * Build a request for a JsonObjectRequest
	 * 
	 * @param dataResponseCallBack
	 * @param requestId
	 * @param method
	 * @param url
	 * @param parameters
	 * @param headers
	 * @return
	 */
	private JsonObjectRequest buildJsonObjectRequest(final DataResponseCallBack dataResponseCallBack, final String requestId,
			int method, String url, final Map<String, String> parameters, final Map<String, String> headers)
	{

		JSONObject parametersJsonObject = null;
		final String urlFinal;

		if (parameters != null)
		{

			switch (method)
			{
			// For Get calls we put the parameters in the URL
				case Method.GET:
					url += HttpUtils.URL_QUESTION_MARK + HttpUtils.parametersToUrl(parameters);
					break;

				default:
					parametersJsonObject = new JSONObject(parameters);
					break;
			}

		}

		urlFinal = url;

		// Doing the request
		return new JsonObjectRequest(method, urlFinal, parametersJsonObject, new Response.Listener<JSONObject>()
		{
			@Override
			public void onResponse(JSONObject response)
			{
				dataResponseCallBack.onResponse(DataResponse.createSuccessResponse(response.toString(), true));
			}
		}, new Response.ErrorListener()
		{
			@Override
			public void onErrorResponse(VolleyError error)
			{
				String errorMsg = error.getLocalizedMessage();

				if (error.networkResponse != null && error.networkResponse.data != null)
				{
					errorMsg = new String(error.networkResponse.data);
				}

				if (StringUtils.isBlank(errorMsg))
				{
					errorMsg = error.toString();
				}

				Log.e(TAG, "Error with the Volley request " + requestId + ": " + errorMsg);
				dataResponseCallBack.onError(DataResponse.createErrorResponse(errorMsg, true));
			}
		})
		{

			@Override
			public Map<String, String> getHeaders() throws AuthFailureError
			{
				if (headers != null)
				{
					return new HashMap<String, String>(headers);
				}
				else
				{
					return Collections.emptyMap();
				}
			}

			@Override
			public byte[] getBody()
			{
				String returnParams = HttpUtils.parametersToUrl(parameters);

				if (StringUtils.isNotBlank(returnParams))
				{
					return returnParams.getBytes();
				}
				else
				{
					return new byte[0];
				}
			}

			@Override
			public String getBodyContentType()
			{
				return HttpUtils.CONTENT_TYPE_URLENC;
			};

			@Override
			protected Response<JSONObject> parseNetworkResponse(NetworkResponse response)
			{
				try
				{
					String jsonString = new String(response.data, HttpUtils.ENCODING_UTF8);
					JSONObject jsonObject = new JSONObject();

					if (StringUtils.isNotBlank(jsonString))
					{
						jsonObject = new JSONObject(jsonString);
					}

					return Response.success(jsonObject, ignoreCacheHeaders(response));
				}
				catch (UnsupportedEncodingException e)
				{
					return Response.error(new ParseError(e));
				}
				catch (JSONException je)
				{
					return Response.error(new ParseError(je));
				}
			}

		};

	}

	/**
	 * Ignore cache headers on Webservice response
	 * 
	 * @param response
	 * @return
	 */
	private Cache.Entry ignoreCacheHeaders(NetworkResponse response)
	{
		long now = System.currentTimeMillis();

		// In PersistenceHelper.CACHE_EXPIRE_IN_DAY cache will be refreshed on
		// background
		long cacheHitButRefreshed = PersistenceHelper.CACHE_EXPIRE_IN_DAYS * 60 * 60 * 60 * 1000;

		// In PersistenceHelper.CACHE_EXPIRE_IN_DAY cache will expire completely
		long cacheExpired = PersistenceHelper.CACHE_EXPIRE_IN_DAYS * 60 * 60 * 60 * 1000;

		Map<String, String> headers = response.headers;

		long serverDate = 0;
		String serverEtag = null;
		String headerValue;

		headerValue = headers.get(HEADER_DATE);
		if (headerValue != null)
		{
			try
			{
				// Parse date in RFC1123 format if this header contains one
				serverDate = DateUtils.parseDate(headerValue).getTime();
			}
			catch (DateParseException e)
			{
				// Date in invalid format, fallback to 0
				serverDate = 0;
			}
		}

		serverEtag = headers.get(HEADER_ETAG);

		long softExpire = now + cacheHitButRefreshed;
		long ttl = now + cacheExpired;

		Cache.Entry entry = new Cache.Entry();
		entry.data = response.data;
		entry.etag = serverEtag;
		entry.softTtl = softExpire;
		entry.ttl = ttl;
		entry.serverDate = serverDate;
		entry.responseHeaders = headers;

		return entry;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#cancel(java.lang.String)
	 */
	@Override
	public void cancel(String requestId)
	{
		mQueue.cancelAll(requestId);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#pause()
	 */
	@Override
	public void pause()
	{
		mQueue.stop();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.manager.PersistenceManager#start()
	 */
	@Override
	public void start()
	{
		mQueue.start();
	}
}
