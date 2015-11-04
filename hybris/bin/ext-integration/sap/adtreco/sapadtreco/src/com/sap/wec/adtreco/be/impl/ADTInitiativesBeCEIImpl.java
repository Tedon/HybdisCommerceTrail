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
package com.sap.wec.adtreco.be.impl;

import de.hybris.platform.sap.core.bol.backend.BackendBusinessObjectBase;
import de.hybris.platform.sap.core.bol.backend.BackendType;
import de.hybris.platform.sap.core.configuration.http.HTTPDestination;
import de.hybris.platform.sap.core.configuration.http.impl.HTTPDestinationServiceImpl;

import java.io.IOException;
import java.net.URISyntaxException;

import javax.annotation.Resource;

import org.apache.olingo.odata2.api.ep.entry.ODataEntry;
import org.apache.olingo.odata2.api.ep.feed.ODataFeed;
import org.apache.olingo.odata2.api.exception.ODataException;

import com.sap.wec.adtreco.be.ODataClientService;
import com.sap.wec.adtreco.be.intf.ADTInitiativesBE;

/**
 *
 */
@BackendType("CEI")
public class ADTInitiativesBeCEIImpl extends BackendBusinessObjectBase implements ADTInitiativesBE
{
	@Resource(name = "sapCoreHTTPDestinationService")
	private HTTPDestinationServiceImpl httpDestinationService;
	private HTTPDestination httpDestination;

	private static final String SERVICE_URL = "/sap/opu/odata/sap/CUAN_COMMON_SRV";
	protected String path;
	protected ODataClientService clientService;
	protected String httpDestinationId;

	public ODataFeed getInitiatives(final String select, final String filter, final String entitySetName, final String expand)
			throws ODataException, URISyntaxException, IOException
	{
		loadDestinations();
		ODataFeed feed = null;
		feed = this.clientService.readFeed(this.httpDestination, path, ODataClientService.APPLICATION_XML, entitySetName, select, filter, expand);
		return feed;
	}

	public ODataEntry getInitiative(final String select, final String keyValue, final String entitySetName) throws ODataException, IOException, URISyntaxException
	{
		loadDestinations();
		ODataEntry entry = null;
		entry = this.clientService.readEntry(this.httpDestination, path, ODataClientService.APPLICATION_XML, entitySetName, select, null, keyValue);
		return entry;
	}

	public void loadDestinations()
	{
		if (this.httpDestinationService != null)
		{
			this.httpDestination = this.httpDestinationService.getHTTPDestination(httpDestinationId);
			if (this.httpDestination != null)
			{
				this.path = this.httpDestination.getTargetURL() + SERVICE_URL;
			}
		}
	}
	
	/**
	 * @return the path
	 */
	public String getPath()
	{
		return this.path;
	}

	/**
	 * @param path
	 *           the path to set
	 */
	public void setPath(final String path)
	{
		this.path = path;
	}
	
	public ODataClientService getClientService()
	{
		return clientService;
	}

	public void setClientService(final ODataClientService clientService)
	{
		this.clientService = clientService;
	}

	public String getHttpDestinationId()
	{
		return httpDestinationId;
	}

	public void setHttpDestinationId(final String httpDestinationId)
	{
		this.httpDestinationId = httpDestinationId;
	}
}
