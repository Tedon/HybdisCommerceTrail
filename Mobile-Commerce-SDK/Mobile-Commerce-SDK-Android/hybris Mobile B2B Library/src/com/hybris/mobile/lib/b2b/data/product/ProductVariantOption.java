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

import java.util.Iterator;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.hybris.mobile.lib.b2b.data.product.Product.Image;



public class ProductVariantOption
{

	private static final String IMG_FORMAT_THUMB = "thumbnail";

	private String code;
	private Price priceData;
	private ProductStock stock;
	private List<VariantOptionQualifier> variantOptionQualifiers;

	public String getCode()
	{
		return code;
	}

	public void setCode(String code)
	{
		this.code = code;
	}

	public List<VariantOptionQualifier> getVariantOptionImages()
	{
		return variantOptionQualifiers;
	}

	public void setVariantOptionImages(List<VariantOptionQualifier> variantOptionQualifiers)
	{
		this.variantOptionQualifiers = variantOptionQualifiers;
	}

	public ProductStock getStock()
	{
		return stock;
	}

	public void setStock(ProductStock stock)
	{
		this.stock = stock;
	}

	public Price getPriceData()
	{
		return priceData;
	}

	public void setPriceData(Price priceData)
	{
		this.priceData = priceData;
	}

	/**
	 * Get the thumbnail url from the product images
	 * 
	 * @return
	 */
	public String getImageThumbmailUrl()
	{

		String thumbnail = "";

		if (variantOptionQualifiers != null && !variantOptionQualifiers.isEmpty())
		{

			boolean imageFound = false;
			Iterator<VariantOptionQualifier> iterImages = variantOptionQualifiers.iterator();

			while (iterImages.hasNext() && !imageFound)
			{
				VariantOptionQualifier variantOptionQualifier = iterImages.next();

				if (StringUtils.equals(variantOptionQualifier.getImage().getFormat(), IMG_FORMAT_THUMB))
				{
					thumbnail = variantOptionQualifier.getImage().getUrl();
					imageFound = true;
				}
			}

		}

		return thumbnail;

	}

	public static class VariantOptionQualifier
	{

		private Image image;

		public Image getImage()
		{
			return image;
		}

		public void setImage(Image image)
		{
			this.image = image;
		}
	}

}
