/*
 * [y] hybris Platform
 *
 * Copyright (c) 2000-2014 hybris AG
 * All rights reserved.
 *
 * This software is the confidential and proprietary information of hybris
 * ("Confidential Information"). You shall not disclose such Confidential
 * Information and shall use it only in accordance with the terms of the
 * license agreement you entered into with hybris.
 *
 *
 */
package com.sap.hybris.reco.common.util;

import de.hybris.platform.sap.core.configuration.global.SAPGlobalConfigurationService;
import de.hybris.platform.sap.core.configuration.http.HTTPDestination;
import de.hybris.platform.sap.core.configuration.http.impl.HTTPDestinationServiceImpl;
import de.hybris.platform.sap.core.module.ModuleConfigurationAccess;

import javax.annotation.Resource;


/**
 *
 */
public class HMCConfigurationReader
{
	@Resource(name = "sapCoreDefaultSAPGlobalConfigurationService")
	private SAPGlobalConfigurationService globalConfigurationService;
	
	@Resource(name = "sapCoreHTTPDestinationService")
	private HTTPDestinationServiceImpl httpDestinationService;
	private HTTPDestination httpDestination;
	private String httpDestinationId;
	
	@Resource(name = "sapPRIModuleConfigurationAccess")
	private ModuleConfigurationAccess baseStoreConfigurationService;
	
	private String rfcDestinationId;
	
	private String userType;
	private String itemType;


	/**
	 * Get the extensions configuration parameters from the hMC SAP Global Configuration
	 */
	public void loadPRIConfiguration()
	{
		final String httpId = (String) globalConfigurationService.getProperty("sapproductrecommendation_httpdest");		
		this.setHttpDestinationId(httpId);
		loadHTTPDestination();
	}

	/**
	 * Get the HTTP Destination details from the hMC SAP Integration HTTP Destination configuration
	 * 
	 */
	public void loadHTTPDestination()
	{

		if (this.httpDestinationService != null)
		{
			this.httpDestination = this.httpDestinationService.getHTTPDestination(this.getHttpDestinationId());
		}
	}
	
	/**
	 * Get the RFC Destination details from the hMC SAP Integration HTTP Destination configuration
	 * 
	 */
	public void loadRFCConfiguration()
	{
		final String rfcId = (String) globalConfigurationService.getProperty("sapproductrecommendation_rfcdest");
		this.setRfcDestinationId(rfcId);		
	}
	
	/**
	 * Get the User Type from the PRI configuration in the Base Store configuration
	 * 
	 */
	public void loadUserTypeConfiguration()
	{
		String userType = "";
		if (baseStoreConfigurationService!= null) {
			userType = (String) baseStoreConfigurationService.getProperty("sapproductrecommendation_usertype");
		}
		this.setUserType(userType);		
	}
	
	public SAPGlobalConfigurationService getGlobalConfigurationService()
	{
		return globalConfigurationService;
	}

	public void setGlobalConfigurationService(final SAPGlobalConfigurationService globalConfigurationService)
	{
		this.globalConfigurationService = globalConfigurationService;
	}
	
	public ModuleConfigurationAccess getBaseStoreConfigurationService()
	{
		return baseStoreConfigurationService;
	}


	public void setBaseStoreConfigurationService(final ModuleConfigurationAccess baseStoreConfigurationService)
	{
		this.baseStoreConfigurationService = baseStoreConfigurationService;
	}

	public HTTPDestinationServiceImpl getHttpDestinationService()
	{
		return httpDestinationService;
	}

	public void setHttpDestinationService(final HTTPDestinationServiceImpl httpDestinationService)
	{
		this.httpDestinationService = httpDestinationService;
	}

	public HTTPDestination getHttpDestination()
	{
		return httpDestination;
	}

	public void setHttpDestination(final HTTPDestination httpDestination)
	{
		this.httpDestination = httpDestination;
	}

	public String getHttpDestinationId()
	{
		return httpDestinationId;
	}

	public void setHttpDestinationId(final String httpDestinationId)
	{
		this.httpDestinationId = httpDestinationId;
	}
	

	public String getRfcDestinationId()
	{
		this.loadRFCConfiguration();
		return rfcDestinationId;
	}

	public void setRfcDestinationId(final String rfcDestinationId)
	{
		this.rfcDestinationId = rfcDestinationId;
	}

	public String getUserType()
	{
		this.loadUserTypeConfiguration();
		return userType;
	}

	public void setUserType(final String userType)
	{
		this.userType = userType;
	}
	
	public void setItemType(final String itemType)
	{
		this.itemType = itemType;
	}

	public String getFilterCategory()
	{
		// YTODO Auto-generated method stub
		return null;
	}
	



}
