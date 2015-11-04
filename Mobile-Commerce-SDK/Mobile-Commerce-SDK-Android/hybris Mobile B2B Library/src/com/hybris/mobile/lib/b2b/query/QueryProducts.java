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
package com.hybris.mobile.lib.b2b.query;

import java.util.ArrayList;
import java.util.List;


public class QueryProducts extends QueryList
{

	private String searchText;
	private List<QueryFacet> queryFacets = new ArrayList<QueryFacet>();
	private String idCategory;

	public String getSearchText()
	{
		return searchText;
	}

	public void setSearchText(String searchText)
	{
		this.searchText = searchText;
	}

	public String getIdCategory()
	{
		return idCategory;
	}

	public void setIdCategory(String idCategory)
	{
		this.idCategory = idCategory;
	}

	public List<QueryFacet> getQueryFacets()
	{
		return queryFacets;
	}

	public void setQueryFacets(List<QueryFacet> queryFacets)
	{
		this.queryFacets = queryFacets;
	}

}
