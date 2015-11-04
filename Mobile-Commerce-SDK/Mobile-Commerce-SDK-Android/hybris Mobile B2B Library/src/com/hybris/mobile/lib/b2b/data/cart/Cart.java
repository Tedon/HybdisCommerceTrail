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

import java.util.List;

import com.hybris.mobile.lib.b2b.data.Promotion;
import com.hybris.mobile.lib.b2b.data.order.OrderProduct;
import com.hybris.mobile.lib.b2b.data.product.Price;


public class Cart
{
	private String code;
	private Price totalDiscounts;
	private Price subTotal;
	private Price totalTax;
	private Price totalPrice;
	private Price orderDiscounts;
	private Price productDiscounts;
	private List<OrderProduct> entries;
	private int totalUnitCount;
	private Price deliveryCost;
	private Price totalPriceWithTax;
	private List<Promotion> appliedOrderPromotions;
	private List<Promotion> appliedProductPromotions;

	public String getCode()
	{
		return code;
	}

	public void setCode(String code)
	{
		this.code = code;
	}

	public Price getTotalPrice()
	{
		return totalPrice;
	}

	public void setTotalPrice(Price totalPrice)
	{
		this.totalPrice = totalPrice;
	}

	public Price getTotalDiscounts()
	{
		return totalDiscounts;
	}

	public void setTotalDiscounts(Price totalDiscounts)
	{
		this.totalDiscounts = totalDiscounts;
	}

	public Price getSubTotal()
	{
		return subTotal;
	}

	public void setSubTotal(Price subTotal)
	{
		this.subTotal = subTotal;
	}

	public Price getTotalTax()
	{
		return totalTax;
	}

	public void setTotalTax(Price totalTax)
	{
		this.totalTax = totalTax;
	}

	public List<OrderProduct> getEntries()
	{
		return entries;
	}

	public void setEntries(List<OrderProduct> entries)
	{
		this.entries = entries;
	}

	public int getTotalUnitCount()
	{
		return totalUnitCount;
	}

	public void setTotalUnitCount(int totalUnitCount)
	{
		this.totalUnitCount = totalUnitCount;
	}

	public Price getDeliveryCost()
	{
		return deliveryCost;
	}

	public void setDeliveryCost(Price deliveryCost)
	{
		this.deliveryCost = deliveryCost;
	}

	public Price getTotalPriceWithTax()
	{
		return totalPriceWithTax;
	}

	public void setTotalPriceWithTax(Price totalPriceWithTax)
	{
		this.totalPriceWithTax = totalPriceWithTax;
	}

	public List<Promotion> getAppliedOrderPromotions()
	{
		return appliedOrderPromotions;
	}

	public void setAppliedOrderPromotions(List<Promotion> appliedOrderPromotions)
	{
		this.appliedOrderPromotions = appliedOrderPromotions;
	}

	public List<Promotion> getAppliedProductPromotions()
	{
		return appliedProductPromotions;
	}

	public void setAppliedProductPromotions(List<Promotion> appliedProductPromotions)
	{
		this.appliedProductPromotions = appliedProductPromotions;
	}

	public Price getOrderDiscounts()
	{
		return orderDiscounts;
	}

	public void setOrderDiscounts(Price orderDiscounts)
	{
		this.orderDiscounts = orderDiscounts;
	}

	public Price getProductDiscounts()
	{
		return productDiscounts;
	}

	public void setProductDiscounts(Price productDiscounts)
	{
		this.productDiscounts = productDiscounts;
	}

}
