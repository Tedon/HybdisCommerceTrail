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
package com.hybris.mobile.lib.b2b.data.order;

import com.hybris.mobile.lib.b2b.data.Promotion;
import com.hybris.mobile.lib.b2b.data.product.Price;
import com.hybris.mobile.lib.b2b.data.product.Product;


public class OrderProduct
{

	private String code;
	private Price basePrice;
	private Price totalPrice;
	private int quantity;
	private int entryNumber;
	private Product product;
	private Promotion promotion;


	public String getCode()
	{
		return code;
	}

	public void setCode(String code)
	{
		this.code = code;
	}

	public int getEntryNumber()
	{
		return entryNumber;
	}

	public void setEntryNumber(int entryNumber)
	{
		this.entryNumber = entryNumber;
	}

	public Price getBasePrice()
	{
		return basePrice;
	}

	public void setBasePrice(Price basePrice)
	{
		this.basePrice = basePrice;
	}

	public Price getTotalPrice()
	{
		return totalPrice;
	}

	public void setTotalPrice(Price totalPrice)
	{
		this.totalPrice = totalPrice;
	}

	public int getQuantity()
	{
		return quantity;
	}

	public void setQuantity(int quantity)
	{
		this.quantity = quantity;
	}

	public Product getProduct()
	{
		return product;
	}

	public void setProduct(Product product)
	{
		this.product = product;
	}

	public Promotion getPromotion()
	{
		return promotion;
	}

	public void setPromotion(Promotion promotion)
	{
		this.promotion = promotion;
	}

}
