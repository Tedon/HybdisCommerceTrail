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
package com.hybris.mobile.lib.http.test;

import java.lang.reflect.Type;
import java.util.List;

import android.test.AndroidTestCase;

import com.google.gson.reflect.TypeToken;
import com.hybris.mobile.lib.http.converter.DataConverter;
import com.hybris.mobile.lib.http.converter.JsonDataConverter;
import com.hybris.mobile.lib.http.converter.exception.DataConverterException;


public class DataConverterTests extends AndroidTestCase
{

	private String dummyPojoJson = "{\"firstName\":\"testFirstName\", \"lastName\":\"testLastName\", \"phoneNumber\":\"testPhoneNumber\"}";
	private String dummyPojoWithPropertyJson = "{\"dummyPojo\":" + dummyPojoJson + "}";
	private String dummyPojoJsonList = "[" + dummyPojoJson + "," + dummyPojoJson + "," + dummyPojoJson + "," + dummyPojoJson + "]";
	private String dummyPojoJsonListWithPropertyJson = "{\"dummyPojo\":[" + dummyPojoJson + "," + dummyPojoJson + ","
			+ dummyPojoJson + "," + dummyPojoJson + "]}";
	private DataConverter dataConverter;

	@Override
	protected void setUp() throws Exception
	{
		super.setUp();
		dataConverter = new JsonDataConverter()
		{

			@Override
			public <T> Type getAssociatedTypeFromClass(Class<T> className)
			{
				Type listType = null;

				if (className == DummyPojo.class)
				{
					listType = new TypeToken<List<DummyPojo>>()
					{}.getType();
				}

				return listType;
			}

			@Override
			public String createErrorMessage(String errorMessage)
			{
				return null;
			}
		};
	}

	public void testConvertFrom() throws DataConverterException
	{
		DummyPojo dummyPojo = dataConverter.convertFrom(DummyPojo.class, dummyPojoJson);
		assertTrue(dummyPojo != null && dummyPojo instanceof DummyPojo);
	}

	public void testConvertFromProperty() throws DataConverterException
	{
		DummyPojo dummyPojo = dataConverter.convertFrom(DummyPojo.class, dummyPojoWithPropertyJson, "dummyPojo");
		assertTrue(dummyPojo != null && dummyPojo instanceof DummyPojo);
	}

	public void testConvertFromPropertyKO() throws DataConverterException
	{
		try
		{
			dataConverter.convertFrom(DummyPojo.class, dummyPojoWithPropertyJson, "unknownProperty");
		}
		catch (DataConverterException e)
		{
			assertTrue(true);
		}
	}

	public void testConvertFromList() throws DataConverterException
	{
		List<DummyPojo> dummyPojos = dataConverter.convertFromList(DummyPojo.class, dummyPojoJsonList);
		assertTrue(dummyPojos != null && !dummyPojos.isEmpty());
	}

	public void testConvertFromListFromProperty() throws DataConverterException
	{
		List<DummyPojo> dummyPojos = dataConverter.convertFromList(DummyPojo.class, dummyPojoJsonListWithPropertyJson, "dummyPojo");
		assertTrue(dummyPojos != null && !dummyPojos.isEmpty());
	}

	public void testConvertFromListFromPropertyKO() throws DataConverterException
	{
		try
		{
			dataConverter.convertFromList(DummyPojo.class, dummyPojoJsonListWithPropertyJson, "unknownProperty");
		}
		catch (DataConverterException e)
		{
			assertTrue(true);
		}
	}

	@Override
	protected void tearDown() throws Exception
	{
		super.tearDown();
	}

	class DummyPojo
	{

		private List<DummyPojo> dummyPojos;
		private DummyPojo dummyPojo;
		private String firstName;
		private String lastName;
		private String phoneNumber;

		public String getFirstName()
		{
			return firstName;
		}

		public void setFirstName(String firstName)
		{
			this.firstName = firstName;
		}

		public String getLastName()
		{
			return lastName;
		}

		public void setLastName(String lastName)
		{
			this.lastName = lastName;
		}

		public String getPhoneNumber()
		{
			return phoneNumber;
		}

		public void setPhoneNumber(String phoneNumber)
		{
			this.phoneNumber = phoneNumber;
		}

		public DummyPojo getDummyPojo()
		{
			return dummyPojo;
		}

		public void setDummyPojo(DummyPojo dummyPojo)
		{
			this.dummyPojo = dummyPojo;
		}


		public List<DummyPojo> getDummyPojos()
		{
			return dummyPojos;
		}

		public void setDummyPojos(List<DummyPojo> dummyPojos)
		{
			this.dummyPojos = dummyPojos;
		}
	}

}
