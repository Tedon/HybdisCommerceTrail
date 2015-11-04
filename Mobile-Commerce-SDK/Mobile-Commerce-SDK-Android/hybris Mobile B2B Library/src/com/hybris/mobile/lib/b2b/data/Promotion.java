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
package com.hybris.mobile.lib.b2b.data;

import java.util.List;


public class Promotion
{
	private String description;
	private List<PromotionEntry> consumedEntries;
	private PromotionDetail promotion;

	public String getDescription()
	{
		return description;
	}

	public void setDescription(String description)
	{
		this.description = description;
	}


	public List<PromotionEntry> getConsumedEntries()
	{
		return consumedEntries;
	}

	public void setConsumedEntries(List<PromotionEntry> consumedEntries)
	{
		this.consumedEntries = consumedEntries;
	}

	public PromotionDetail getPromotionDetail()
	{
		return promotion;
	}

	public void setPromotionDetail(PromotionDetail promotion)
	{
		this.promotion = promotion;
	}

	public static class PromotionDetail
	{

		private String code;

		public String getCode()
		{
			return code;
		}

		public void setCode(String code)
		{
			this.code = code;
		}
	}
}
