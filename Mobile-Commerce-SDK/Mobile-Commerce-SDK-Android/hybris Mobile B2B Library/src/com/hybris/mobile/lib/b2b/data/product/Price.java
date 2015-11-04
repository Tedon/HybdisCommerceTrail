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



public class Price
{

	private String currencyIso;
	private String formattedValue;
	private String priceType;
	private String value;
	private int maxQuantity;
	private int minQuantity;

	public String getCurrencyIso()
	{
		return currencyIso;
	}

	public void setCurrencyIso(String currencyIso)
	{
		this.currencyIso = currencyIso;
	}

	public String getFormattedValue()
	{
		return formattedValue;
	}

	public void setFormattedValue(String formattedValue)
	{
		this.formattedValue = formattedValue;
	}

	public String getPriceType()
	{
		return priceType;
	}

	public void setPriceType(String priceType)
	{
		this.priceType = priceType;
	}

	public String getValue()
	{
		return value;
	}

	public void setValue(String value)
	{
		this.value = value;
	}

	public int getMaxQuantity()
	{
		return maxQuantity;
	}

	public void setMaxQuantity(int maxQuantity)
	{
		this.maxQuantity = maxQuantity;
	}

	public int getMinQuantity()
	{
		return minQuantity;
	}

	public void setMinQuantity(int minQuantity)
	{
		this.minQuantity = minQuantity;
	}

}
