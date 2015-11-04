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
package com.hybris.mobile.lib.b2b.utils;

import java.lang.reflect.Type;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.google.gson.reflect.TypeToken;
import com.hybris.mobile.lib.b2b.data.Address;
import com.hybris.mobile.lib.b2b.data.Category;
import com.hybris.mobile.lib.b2b.data.DeliveryMode;
import com.hybris.mobile.lib.b2b.data.PaymentInfo;
import com.hybris.mobile.lib.b2b.data.Promotion;
import com.hybris.mobile.lib.b2b.data.UserInformation;
import com.hybris.mobile.lib.b2b.data.cart.Cart;
import com.hybris.mobile.lib.b2b.data.costcenter.CostCenter;
import com.hybris.mobile.lib.b2b.data.order.Order;
import com.hybris.mobile.lib.b2b.data.product.Product;
import com.hybris.mobile.lib.b2b.data.product.ProductBaseOption;


/**
 * Utility class for json conversion
 */
public class JsonUtils
{

	private static final String MSG_TO_REPLACE = "MSG_TO_REPLACE";
	private static final String ERROR_MESSAGE_JSON = "{'errors':[{'message':'" + MSG_TO_REPLACE + "'}]}";

	/**
	 * Return the associated type of the class
	 * 
	 * @param className
	 * @return
	 */
	public static <T> Type getAssociatedTypeFromClass(Class<T> className)
	{
		Type listType = null;

		if (className == null)
		{
			throw new IllegalArgumentException();
		}

		if (className == Category.class)
		{
			listType = new TypeToken<List<Category>>()
			{}.getType();
		}
		else if (className == Cart.class)
		{
			listType = new TypeToken<List<Cart>>()
			{}.getType();
		}
		else if (className == Product.class)
		{
			listType = new TypeToken<List<Product>>()
			{}.getType();
		}
		else if (className == CostCenter.class)
		{
			listType = new TypeToken<List<CostCenter>>()
			{}.getType();
		}
		else if (className == Address.class)
		{
			listType = new TypeToken<List<Address>>()
			{}.getType();
		}
		else if (className == DeliveryMode.class)
		{
			listType = new TypeToken<List<DeliveryMode>>()
			{}.getType();
		}
		else if (className == PaymentInfo.class)
		{
			listType = new TypeToken<List<PaymentInfo>>()
			{}.getType();
		}
		else if (className == Order.class)
		{
			listType = new TypeToken<List<Order>>()
			{}.getType();
		}
		else if (className == ProductBaseOption.class)
		{
			listType = new TypeToken<List<ProductBaseOption>>()
			{}.getType();
		}
		else if (className == Promotion.class)
		{
			listType = new TypeToken<List<Promotion>>()
			{}.getType();
		}
		else if (className == Error.class)
		{
			listType = new TypeToken<List<Error>>()
			{}.getType();
		}
		else if (className == UserInformation.class)
		{
			listType = new TypeToken<List<UserInformation>>()
			{}.getType();
		}

		return listType;
	}

	public static String createErrorMessage(String errorMessage)
	{
		return ERROR_MESSAGE_JSON.replace(MSG_TO_REPLACE, StringUtils.isNotBlank(errorMessage) ? errorMessage : "");
	}

}
