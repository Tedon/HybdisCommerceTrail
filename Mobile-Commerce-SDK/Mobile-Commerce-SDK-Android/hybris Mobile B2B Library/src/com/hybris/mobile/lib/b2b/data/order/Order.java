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

import java.util.List;

import com.hybris.mobile.lib.b2b.data.Address;
import com.hybris.mobile.lib.b2b.data.DeliveryMode;
import com.hybris.mobile.lib.b2b.data.PaymentInfo;
import com.hybris.mobile.lib.b2b.data.Promotion;
import com.hybris.mobile.lib.b2b.data.User;
import com.hybris.mobile.lib.b2b.data.product.Price;


public class Order
{
	private String code;
	private String placed;
	private String statusDisplay;
	private String created;
	private Address deliveryAddress;
	private DeliveryMode deliveryMode;
	private PaymentInfo paymentInfo;
	private Price subTotal;
	private Price totalTax;
	private Price deliveryCost;
	private Price orderDiscounts;
	private Price productDiscounts;
	private Price totalDiscounts;
	private Price totalPrice;
	private List<DeliveryOrderGroups> deliveryOrderGroups;
	private List<OrderProduct> entries;
	private User user;
	private List<Promotion> appliedOrderPromotions;
	private List<Promotion> appliedProductPromotions;
	private String deliveryItemsQuantity;



	public List<OrderProduct> getEntries()
	{
		return entries;
	}

	public void setEntries(List<OrderProduct> entries)
	{
		this.entries = entries;
	}

	public List<DeliveryOrderGroups> getDeliveryOrderGroups()
	{
		return deliveryOrderGroups;
	}

	public void setDeliveryOrderGroups(List<DeliveryOrderGroups> deliveryOrderGroups)
	{
		this.deliveryOrderGroups = deliveryOrderGroups;
	}

	public String getCreated()
	{
		return created;
	}

	public void setCreated(String created)
	{
		this.created = created;
	}

	public Address getDeliveryAddress()
	{
		return deliveryAddress;
	}

	public void setDeliveryAddress(Address deliveryAddress)
	{
		this.deliveryAddress = deliveryAddress;
	}

	public DeliveryMode getDeliveryMode()
	{
		return deliveryMode;
	}

	public void setDeliveryMode(DeliveryMode deliveryMode)
	{
		this.deliveryMode = deliveryMode;
	}

	public PaymentInfo getPaymentInfo()
	{
		return paymentInfo;
	}

	public void setPaymentInfo(PaymentInfo paymentInfo)
	{
		this.paymentInfo = paymentInfo;
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

	public Price getDeliveryCost()
	{
		return deliveryCost;
	}

	public void setDeliveryCost(Price deliveryCost)
	{
		this.deliveryCost = deliveryCost;
	}

	public Price getTotalPrice()
	{
		return totalPrice;
	}

	public void setTotalPrice(Price totalPrice)
	{
		this.totalPrice = totalPrice;
	}

	public String getCode()
	{
		return code;
	}

	public void setCode(String code)
	{
		this.code = code;
	}

	public String getPlaced()
	{
		return placed;
	}

	public void setPlaced(String placed)
	{
		this.placed = placed;
	}

	public String getStatusDisplay()
	{
		return statusDisplay;
	}

	public void setStatusDisplay(String statusDisplay)
	{
		this.statusDisplay = statusDisplay;
	}

	public Price getTotalDiscounts()
	{
		return totalDiscounts;
	}

	public void setTotalDiscounts(Price totalDiscounts)
	{
		this.totalDiscounts = totalDiscounts;
	}

	public User getUser()
	{
		return user;
	}

	public void setUser(User user)
	{
		this.user = user;
	}

	public List<Promotion> getAppliedOrderPromotions()
	{
		return appliedOrderPromotions;
	}

	public void setAppliedOrderPromotions(List<Promotion> appliedOrderPromotions)
	{
		this.appliedOrderPromotions = appliedOrderPromotions;
	}

	public String getDeliveryItemsQuantity()
	{
		return deliveryItemsQuantity;
	}

	public void setDeliveryItemsQuantity(String deliveryItemsQuantity)
	{
		this.deliveryItemsQuantity = deliveryItemsQuantity;
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

	public List<Promotion> getAppliedProductPromotions()
	{
		return appliedProductPromotions;
	}

	public void setAppliedProductPromotions(List<Promotion> appliedProductPromotions)
	{
		this.appliedProductPromotions = appliedProductPromotions;
	}

	public class DeliveryOrderGroups
	{

		private List<OrderProduct> entries;

		public List<OrderProduct> getEntries()
		{
			return entries;
		}

		public void setEntries(List<OrderProduct> entries)
		{
			this.entries = entries;
		}



	}
}
