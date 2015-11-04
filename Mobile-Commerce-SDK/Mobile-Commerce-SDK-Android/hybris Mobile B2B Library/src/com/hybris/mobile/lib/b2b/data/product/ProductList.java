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
package com.hybris.mobile.lib.b2b.data.product;

import java.util.List;

import com.hybris.mobile.lib.b2b.data.Pagination;


public class ProductList
{
	private List<Product> products;
	private Pagination pagination;
	private SpellingSuggestion spellingSuggestion;

	public List<Product> getProducts()
	{
		return products;
	}

	public void setProducts(List<Product> products)
	{
		this.products = products;
	}

	public Pagination getPagination()
	{
		return pagination;
	}

	public void setPagination(Pagination pagination)
	{
		this.pagination = pagination;
	}

	public SpellingSuggestion getSpellingSuggestion()
	{
		return spellingSuggestion;
	}

	public void setSpellingSuggestion(SpellingSuggestion spellingSuggestion)
	{
		this.spellingSuggestion = spellingSuggestion;
	}

}
