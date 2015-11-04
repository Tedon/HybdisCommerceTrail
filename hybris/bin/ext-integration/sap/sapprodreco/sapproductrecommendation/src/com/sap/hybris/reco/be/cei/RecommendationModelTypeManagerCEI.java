package com.sap.hybris.reco.be.cei;

import de.hybris.platform.sap.core.jco.exceptions.BackendException;

import java.io.IOException;
import java.net.URISyntaxException;

import org.apache.olingo.odata2.api.ep.entry.ODataEntry;
import org.apache.olingo.odata2.api.ep.feed.ODataFeed;
import org.apache.olingo.odata2.api.exception.ODataException;

import com.sap.hybris.reco.be.RecommendationModelTypeManager;
import com.sap.hybris.reco.common.util.HMCConfigurationReader;
import com.sap.hybris.reco.common.util.ODataClientService;


/**
 * 
 */
public class RecommendationModelTypeManagerCEI implements RecommendationModelTypeManager
{
	private static final String SERVICE_URL = "/sap/opu/odata/sap/PROD_RECO_SRV";
	protected ODataClientService clientService;
	protected HMCConfigurationReader configuration;

	@Override
	public void initBackendObject() throws BackendException
	{
		configuration.loadPRIConfiguration();
	}
	
	@Override
	public void destroyBackendObject()
	{

	}

	@Override
	public ODataFeed getModelTypes(String entityName, String expand, String select, String filter, String orderby)
			throws ODataException, URISyntaxException, IOException
	{
		configuration.loadPRIConfiguration();
		
		ODataFeed feed = this.clientService.readFeed(configuration.getHttpDestination().getTargetURL()+SERVICE_URL, ODataClientService.APPLICATION_XML, entityName,
				expand, select, filter, orderby, configuration.getHttpDestination().getUserid(), configuration.getHttpDestination().getPassword());

		return feed;
	}

	public ODataClientService getClientService()
	{
		return clientService;
	}

	public void setClientService(ODataClientService clientService)
	{
		this.clientService = clientService;
	}

	public HMCConfigurationReader getConfiguration()
	{
		return configuration;
	}

	public void setConfiguration(HMCConfigurationReader configuration)
	{
		this.configuration = configuration;
	}
}
