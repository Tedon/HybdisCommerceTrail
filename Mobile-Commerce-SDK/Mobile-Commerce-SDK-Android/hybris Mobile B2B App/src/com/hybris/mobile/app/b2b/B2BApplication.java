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

import java.lang.reflect.Type;

import android.app.Application;
import android.content.Context;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;

import com.hybris.mobile.app.b2b.broadcast.LogoutBroadcastReceiver;
import com.hybris.mobile.lib.b2b.helper.SecurityHelper;
import com.hybris.mobile.lib.b2b.service.ContentServiceHelper;
import com.hybris.mobile.lib.b2b.service.OCCServiceHelper;
import com.hybris.mobile.lib.b2b.utils.JsonUtils;
import com.hybris.mobile.lib.http.converter.DataConverter;
import com.hybris.mobile.lib.http.converter.JsonDataConverter;
import com.hybris.mobile.lib.http.manager.PersistenceManager;
import com.hybris.mobile.lib.http.manager.volley.VolleyPersistenceManager;


/**
 * Main Application class to manage and provide functionality over the apps
 */
public class B2BApplication extends Application
{

	protected static final String LOG = B2BApplication.class.getCanonicalName();
	private Configuration mConfiguration;
	private ContentServiceHelper mContentServiceHelper;
	private static B2BApplication mInstance;

	public void onCreate()
	{
		super.onCreate();
		mInstance = this;

		// Create the content service helper specifiyng the persistence manager and data converter that we want to use on the B2B Library
		PersistenceManager persistenceManager = new VolleyPersistenceManager(this);
		DataConverter dataConverter = new JsonDataConverter()
		{

			@Override
			public <T> Type getAssociatedTypeFromClass(Class<T> className)
			{
				return JsonUtils.getAssociatedTypeFromClass(className);
			}

			@Override
			public String createErrorMessage(String errorMessage)
			{
				return JsonUtils.createErrorMessage(errorMessage);
			}

		};

		// Create the content service helper
		mContentServiceHelper = new OCCServiceHelper(this, persistenceManager, dataConverter);

		// Build the configuration for the app
		mConfiguration = Configuration.buildConfiguration(this);

		// Register broadcast for Logout from the B2B Library
		LocalBroadcastManager.getInstance(this).registerReceiver(new LogoutBroadcastReceiver(),
				new IntentFilter(getString(R.string.intent_action_logout)));
	}

	/**
	 * Get the String value associated with the key on the shared preferences
	 * 
	 * @param key
	 * @param defaultValue
	 * @return
	 */
	public static String getStringFromSharedPreferences(String key, String defaultValue)
	{
		return SecurityHelper.getStringFromSecureSharedPreferences(getSharedPreferences(), key, defaultValue);
	}

	/**
	 * Get the int value associated with the key on the shared preferences
	 * 
	 * @param key
	 * @param defaultValue
	 * @return
	 */
	public static int getIntFromSharedPreferences(String key, int defaultValue)
	{
		return getSharedPreferences().getInt(key, defaultValue);
	}

	/**
	 * Get the long value associated with the key on the shared preferences
	 * 
	 * @param key
	 * @param defaultValue
	 * @return
	 */
	public static long getLongFromSharedPreferences(String key, long defaultValue)
	{
		return getSharedPreferences().getLong(key, defaultValue);
	}

	/**
	 * Get the boolean value associated with the key on the shared preferences
	 * 
	 * @param key
	 * @param defaultValue
	 * @return
	 */
	public static boolean getBooleanFromSharedPreferences(String key, boolean defaultValue)
	{
		return getSharedPreferences().getBoolean(key, defaultValue);
	}

	/**
	 * Set a String pair key/value on the shared preferences
	 * 
	 * @param key
	 * @param value
	 */
	public static void setStringToSharedPreferences(String key, String value)
	{
		SecurityHelper.setStringToSecureSharedPreferences(getSharedPreferences(), key, value);
	}

	/**
	 * Set a Long pair key/value on the shared preferences
	 * 
	 * @param key
	 * @param value
	 */
	public static void setLongToSharedPreferences(String key, long value)
	{
		SharedPreferences.Editor editor = getSharedPreferences().edit();
		editor.putLong(key, value);
		editor.commit();
	}

	/**
	 * Set a int pair key/value on the shard preferences
	 * 
	 * @param key
	 * @param value
	 */
	public static void setIntToSharedPreferences(String key, int value)
	{
		SharedPreferences.Editor editor = getSharedPreferences().edit();
		editor.putInt(key, value);
		editor.commit();
	}

	/**
	 * Set a boolean pair key/value on the shard preferences
	 * 
	 * @param key
	 * @param value
	 */
	public static void setBooleanToSharedPreferences(String key, boolean value)
	{
		SharedPreferences.Editor editor = getSharedPreferences().edit();
		editor.putBoolean(key, value);
		editor.commit();
	}

	/**
	 * Get the shared preferences
	 * 
	 * @return
	 */
	private static SharedPreferences getSharedPreferences()
	{
		return PreferenceManager.getDefaultSharedPreferences(mInstance);
	}

	/**
	 * Return the configuration instance
	 * 
	 * @return
	 */
	public static Configuration getConfiguration()
	{
		return mInstance.mConfiguration;
	}

	/**
	 * Return the content service helper
	 * 
	 * @return
	 */
	public static ContentServiceHelper getContentServiceHelper()
	{
		return mInstance.mContentServiceHelper;
	}

	/**
	 * Return the application context
	 * 
	 * @return
	 */
	public static Context getContext()
	{
		return mInstance.getApplicationContext();
	}

}
