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
package com.hybris.mobile.lib.b2b.data.cart;

import org.apache.commons.lang3.StringUtils;


public class ProductAdded
{
	private String statusCode;
	private int quantity;
	private int quantityAdded;
	private String statusMessage;

	public String getStatusCode()
	{
		return statusCode;
	}

	public void setStatusCode(String statusCode)
	{
		this.statusCode = statusCode;
	}

	public int getQuantity()
	{
		return quantity;
	}

	public void setQuantity(int quantity)
	{
		this.quantity = quantity;
	}

	public int getQuantityAdded()
	{
		return quantityAdded;
	}

	public void setQuantityAdded(int quantityAdded)
	{
		this.quantityAdded = quantityAdded;
	}

	public String getStatusMessage()
	{
		return statusMessage;
	}

	public void setStatusMessage(String statusMessage)
	{
		this.statusMessage = statusMessage;
	}

	public boolean isOutOfStock()
	{
		return StringUtils.equalsIgnoreCase(statusCode, StockLevelEnum.OUT_OF_STOCK.getStatus());
	}

	public boolean isQuantityAddedNotFulfilled()
	{
		return StringUtils.equalsIgnoreCase(statusCode, StockLevelEnum.LOW_STOCK.getStatus());
	}

	private enum StockLevelEnum
	{

		OUT_OF_STOCK("nostock"), LOW_STOCK("lowstock");

		private String status;

		private StockLevelEnum(String status)
		{
			this.status = status;
		}

		public String getStatus()
		{
			return status;
		}

	}

}
