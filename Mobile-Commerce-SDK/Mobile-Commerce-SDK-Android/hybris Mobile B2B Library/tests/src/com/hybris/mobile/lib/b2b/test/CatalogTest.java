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
package com.hybris.mobile.lib.b2b.test;

import java.lang.reflect.Type;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import android.test.AndroidTestCase;

import com.hybris.mobile.lib.b2b.data.Category;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.b2b.service.ContentServiceHelper;
import com.hybris.mobile.lib.b2b.service.OCCServiceHelper;
import com.hybris.mobile.lib.b2b.utils.JsonUtils;
import com.hybris.mobile.lib.http.converter.DataConverter;
import com.hybris.mobile.lib.http.converter.JsonDataConverter;
import com.hybris.mobile.lib.http.manager.volley.VolleyPersistenceManager;
import com.hybris.mobile.lib.http.response.Response;


public class CatalogTest extends AndroidTestCase
{

	private CountDownLatch lock = new CountDownLatch(1);
	private static final int NB_SECONDS_TO_WAIT_ASYNC_FINISH = 60;
	private ContentServiceHelper contentServiceHelper;
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
				return JsonUtils.getAssociatedTypeFromClass(className);
			}

			@Override
			public String createErrorMessage(String errorMessage)
			{
				return JsonUtils.createErrorMessage(errorMessage);
			}
		};
		contentServiceHelper = new OCCServiceHelper(getContext(), new VolleyPersistenceManager(getContext()), dataConverter);
	}

	public void testCreateTreeFromCatalog() throws InterruptedException
	{

		contentServiceHelper.getCatalog(new ResponseReceiver<List<Category>>()
		{

			@Override
			public void onResponse(Response<List<Category>> response)
			{

				// Setting the parents
				for (Category category : response.getData())
				{
					category.setParent(null);
				}

				// Verifying that each category has his parent set and correct
				for (Category category : response.getData())
				{
					verifyCatalogParent(category);
				}

				lock.countDown();
			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();
			}
		}, "test", false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	private void verifyCatalogParent(Category category)
	{
		if (category.getSubcategories() != null)
		{
			// Verifying the subcategories have the good parent
			for (Category subcategories : category.getSubcategories())
			{
				assertTrue(subcategories.getParent().equals(category));
				verifyCatalogParent(subcategories);
			}
		}
	}

	@Override
	protected void tearDown() throws Exception
	{
		super.tearDown();
		contentServiceHelper = null;
		dataConverter = null;
	}

}
