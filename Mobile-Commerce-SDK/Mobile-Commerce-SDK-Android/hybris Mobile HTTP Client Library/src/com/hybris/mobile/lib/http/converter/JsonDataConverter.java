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
package com.hybris.mobile.lib.http.converter;

import java.lang.reflect.Type;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;
import com.hybris.mobile.lib.http.converter.exception.DataConverterException;


/**
 * Convert from JSON Data String to Java Object
 */
public abstract class JsonDataConverter implements DataConverter
{

	public static final String TAG = JsonDataConverter.class.getCanonicalName();
	private static final Gson gson = new Gson();

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.converter.DataConverter#convertFrom(java.lang.Class, java.lang.String)
	 */
	@Override
	public <T> T convertFrom(Class<T> className, String data) throws DataConverterException
	{
		if (StringUtils.isBlank(data) || className == null)
		{
			throw new DataConverterException("Data cannot be null");
		}

		try
		{
			return gson.fromJson(data, className);
		}
		catch (JsonSyntaxException e)
		{
			Log.e(TAG, "Error with the Json conversion. Details: " + e.getLocalizedMessage());
			throw new DataConverterException(e.getLocalizedMessage());
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.converter.DataConverter#convertFrom(java.lang.Class, java.lang.String,
	 * java.lang.String)
	 */
	@Override
	public <T> T convertFrom(Class<T> className, String data, String property) throws DataConverterException
	{
		if (StringUtils.isBlank(data) || className == null || StringUtils.isBlank(property))
		{
			throw new DataConverterException("Data cannot be null");
		}

		try
		{
			JsonParser parser = new JsonParser();
			JsonObject jsonObject = parser.parse(data).getAsJsonObject();

			if (jsonObject != null && jsonObject.get(property) != null)
			{
				return gson.fromJson(jsonObject.get(property), className);
			}
			else
			{
				Log.e(TAG, "Error with the Json conversion. Unknown property \"" + property + "\".");
				throw new DataConverterException("Error with the Json conversion. Unknown property \"" + property + "\".");
			}

		}
		catch (JsonSyntaxException e)
		{
			Log.e(TAG, "Error with the Json conversion. Details: " + e.getLocalizedMessage());
			throw new DataConverterException(e.getLocalizedMessage());
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.b2b.converter.DataConverter#convertFromList(java.lang.Class, java.lang.String)
	 */
	@Override
	public <T> List<T> convertFromList(Class<T> className, String data) throws DataConverterException
	{
		if (StringUtils.isBlank(data) || className == null)
		{
			throw new DataConverterException("Data cannot be null");
		}

		try
		{
			Type listType = getAssociatedTypeFromClass(className);

			if (listType != null)
			{
				return gson.fromJson(data, listType);
			}
			else
			{
				Log.e(TAG, "Error with the Json conversion. No type found for classname \"" + className + "\".");
				throw new DataConverterException("No Type found for " + className);
			}
		}
		catch (JsonSyntaxException e)
		{
			Log.e(TAG, "Error with the Json conversion. Details: " + e.getLocalizedMessage());
			throw new DataConverterException(e.getLocalizedMessage());
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.converter.DataConverter#convertFromList(java.lang.Class, java.lang.String,
	 * java.lang.String)
	 */
	@Override
	public <T> List<T> convertFromList(Class<T> className, String data, String property) throws DataConverterException
	{
		if (StringUtils.isBlank(data) || className == null || StringUtils.isBlank(property))
		{
			throw new DataConverterException("Data cannot be null");
		}

		try
		{
			JsonParser parser = new JsonParser();
			JsonObject jsonObject = parser.parse(data).getAsJsonObject();

			Type listType = getAssociatedTypeFromClass(className);

			if (listType != null)
			{
				if (jsonObject.get(property) != null)
				{
					return gson.fromJson(jsonObject.get(property), listType);
				}
				else
				{
					Log.e(TAG, "Error with the Json conversion. Unknown property \"" + property + "\".");
					throw new DataConverterException("Error with the Json conversion. Unknown property \"" + property + "\".");
				}
			}
			else
			{
				Log.e(TAG, "No Type found for " + className);
				throw new DataConverterException("No Type found for " + className);
			}
		}
		catch (JsonSyntaxException e)
		{
			Log.e(TAG, "Error with the Json conversion. Details: " + e.getLocalizedMessage());
			throw new DataConverterException(e.getLocalizedMessage());
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.hybris.mobile.lib.http.converter.DataConverter#convertTo(java.lang.Object)
	 */
	@Override
	public String convertTo(Object data) throws DataConverterException
	{
		if (data == null)
		{
			throw new DataConverterException();
		}

		return gson.toJson(data);
	}

	/**
	 * Return the Type associated to the Class
	 * 
	 * @param className
	 * @return
	 */
	public abstract <T> Type getAssociatedTypeFromClass(Class<T> className);

}
