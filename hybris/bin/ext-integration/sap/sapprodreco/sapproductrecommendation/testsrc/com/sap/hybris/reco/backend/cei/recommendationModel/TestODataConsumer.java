/*
 * [y] hybris Platform
 *
 * Copyright (c) 2000-2013 hybris AG
 * All rights reserved.
 *
 * This software is the confidential and proprietary information of hybris
 * ("Confidential Information"). You shall not disclose such Confidential
 * Information and shall use it only in accordance with the terms of the
 * license agreement you entered into with hybris.
 *
 *
 */
package com.sap.hybris.reco.backend.cei.recommendationModel;

import java.util.List;

import junit.framework.TestCase;

import com.sap.hybris.reco.dao.SAPRecommendationModelType;
import com.sap.hybris.reco.be.RecommendationModelTypeManager;
import com.sap.hybris.reco.be.cei.RecommendationModelTypeManagerCEI;
import com.sap.hybris.reco.common.util.ODataClientService;
import com.sap.hybris.reco.bo.SAPRecommendationModelTypeReader;
import com.sap.hybris.reco.common.util.HMCConfigurationReader;
/**
 *
 */
public class TestODataConsumer extends TestCase
{
	public void testSearchAll()
	{
		final SAPRecommendationModelTypeReader modelReader = new SAPRecommendationModelTypeReader();
		RecommendationModelTypeManager modelMgr = new RecommendationModelTypeManagerCEI();
		modelMgr.setClientService(new ODataClientService());
		modelMgr.setConfiguration(new HMCConfigurationReader());
		modelReader.setAccessBE(modelMgr);
		
      try
      {
		final List<SAPRecommendationModelType> recommendationModels = modelReader.getAllRecommendationModelTypes();
		assertNotNull(recommendationModels);
		System.out.println(recommendationModels.size());
		assertEquals(true, recommendationModels.size() > 0);
		System.out.println(recommendationModels);
      }
      catch (Exception e)
      {
    
      }

	}

}
