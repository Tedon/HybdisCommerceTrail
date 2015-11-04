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



public class ProductStock
{

	private int stockLevel;
	private String stockLevelStatus;

	public int getStockLevel()
	{
		return stockLevel;
	}

	public void setStockLevel(int stockLevel)
	{
		this.stockLevel = stockLevel;
	}

	public String getStockLevelStatus()
	{
		return stockLevelStatus;
	}

	public void setStockLevelStatus(String stockLevelStatus)
	{
		this.stockLevelStatus = stockLevelStatus;
	}

}
