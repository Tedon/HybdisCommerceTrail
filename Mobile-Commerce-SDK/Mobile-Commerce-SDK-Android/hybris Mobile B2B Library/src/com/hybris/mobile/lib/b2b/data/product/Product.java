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


import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.text.Html;


public class Product
{
	private static final String IMG_FORMAT_THUMB = "thumbnail";
	private static final String IMG_FORMAT_PRODUCT = "product";
	private static final String IMG_TYPE_PRIMARY = "PRIMARY";
	private static final String IMG_TYPE_GALLERY = "GALLERY";
	private Long id;
	private String name;
	private String code;
	private Price price;
	private ProductStock stock;
	private List<Image> images;
	private String url;
	private String description;
	private String summary;
	private List<ProductBaseOption> baseOptions;
	private boolean multidimensional;
	private PriceRange priceRange;
	private String firstVariantImage;
	private String firstVariantCode;
	private List<VariantCategory> categories;
	private List<ProductVariant> variantMatrix;
	private List<Price> volumePrices;

	public Long getId()
	{
		return id;
	}

	public void setId(Long id)
	{
		this.id = id;
	}

	public String getName()
	{
		return Html.fromHtml(name).toString();
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getCode()
	{
		return Html.fromHtml(code).toString();
	}

	public void setCode(String code)
	{
		this.code = code;
	}

	public Price getPrice()
	{
		return price;
	}

	public void setPrice(Price price)
	{
		this.price = price;
	}

	public ProductStock getStock()
	{
		return stock;
	}

	public void setStock(ProductStock stock)
	{
		this.stock = stock;
	}

	public List<Image> getImages()
	{
		return images;
	}

	public void setImages(List<Image> images)
	{
		this.images = images;
	}

	public List<Image> getImagesGallery()
	{
		List<Image> returnList = new ArrayList<Product.Image>();

		if (images != null)
		{

			for (Image image : images)
			{
				if (StringUtils.equals(image.getImageType(), IMG_TYPE_GALLERY))
				{
					returnList.add(image);
				}
			}

		}

		return returnList;
	}

	public String getUrl()
	{
		return url;
	}

	public void setUrl(String url)
	{
		this.url = url;
	}


	public String getDescription()
	{
		return Html.fromHtml(description).toString();
	}

	public void setDescription(String description)
	{
		this.description = description;
	}

	public String getSummary()
	{
		return Html.fromHtml(summary).toString();
	}

	public void setSummary(String summary)
	{
		this.summary = summary;
	}

	/**
	 * Get the thumbnail url from the product images
	 * 
	 * @return
	 */
	public String getImageThumbmailUrl()
	{

		String thumbnail = "";

		if (images != null && !images.isEmpty())
		{

			boolean imageFound = false;
			Iterator<Image> iterImages = images.iterator();

			while (iterImages.hasNext() && !imageFound)
			{
				Image image = iterImages.next();

				if (StringUtils.equals(image.getFormat(), IMG_FORMAT_THUMB)
						&& StringUtils.equals(image.getImageType(), IMG_TYPE_PRIMARY))
				{
					thumbnail = image.getUrl();
					imageFound = true;
				}
			}

		}

		return thumbnail;

	}

	/**
	 * Get the product image url from the product images
	 * 
	 * @return
	 */
	public String getImageProduct()
	{

		String productImg = "";

		if (images != null && !images.isEmpty())
		{

			boolean imageFound = false;
			Iterator<Image> iterImages = images.iterator();

			while (iterImages.hasNext() && !imageFound)
			{
				Image image = iterImages.next();

				// TODO - Switch to IMG_TYPE_PROD but scale the images before showing them
				// Workaround for out of memory issue (Image resolution too big)
				if (StringUtils.equals(image.getFormat(), IMG_FORMAT_PRODUCT)
						&& StringUtils.equals(image.getImageType(), IMG_TYPE_PRIMARY))
				{
					productImg = image.getUrl();
					imageFound = true;
				}
			}

		}

		return productImg;

	}

	public List<ProductBaseOption> getBaseOptions()
	{
		return baseOptions;
	}

	public void setBaseOptions(List<ProductBaseOption> baseOptions)
	{
		this.baseOptions = baseOptions;
	}


	/**
	 * Image of the product
	 */
	public static class Image
	{

		private String format;
		private String url;
		private String imageType;
		private int galleryIndex;
		private String altText;

		public String getUrl()
		{
			return url;
		}

		public void setUrl(String url)
		{
			this.url = url;
		}

		public String getFormat()
		{
			return format;
		}

		public void setFormat(String format)
		{
			this.format = format;
		}

		public String getImageType()
		{
			return imageType;
		}

		public void setImageType(String imageType)
		{
			this.imageType = imageType;
		}

		public int getGalleryIndex()
		{
			return galleryIndex;
		}

		public void setGalleryIndex(int galleryIndex)
		{
			this.galleryIndex = galleryIndex;
		}

		public String getAltText()
		{
			return altText;
		}

		public void setAltText(String altText)
		{
			this.altText = altText;
		}
	}

	public boolean isOutOfStock()
	{
		return stock != null && stock.getStockLevelStatus() != null
				&& StringUtils.equalsIgnoreCase(stock.getStockLevelStatus(), StockLevelEnum.OUT_OF_STOCK.getStatus());
	}

	public boolean isLowStock()
	{
		return stock != null && stock.getStockLevelStatus() != null
				&& StringUtils.equalsIgnoreCase(stock.getStockLevelStatus(), StockLevelEnum.LOW_STOCK.getStatus());
	}

	public boolean isInStock()
	{
		return stock != null && stock.getStockLevelStatus() != null
				&& StringUtils.equalsIgnoreCase(stock.getStockLevelStatus(), StockLevelEnum.IN_STOCK.getStatus());
	}

	public boolean isMultidimensional()
	{
		return multidimensional;
	}

	public void setMultidimensional(boolean multidimensional)
	{
		this.multidimensional = multidimensional;
	}

	public PriceRange getPriceRange()
	{
		return priceRange;
	}

	public void setPriceRange(PriceRange priceRange)
	{
		this.priceRange = priceRange;
	}

	private enum StockLevelEnum
	{

		OUT_OF_STOCK("outOfStock"), LOW_STOCK("lowstock"), IN_STOCK("inStock");

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

	/**
	 * Format price to manage price range if exist otherwise display real price
	 * 
	 * @return
	 */
	public String getPriceRangeFormattedValue()
	{
		String formattedValue = StringUtils.isNotBlank(price.getFormattedValue()) ? price.getFormattedValue() : "";

		if (priceRange.getMaxPrice() != null || priceRange.getMaxPrice() != null)
		{
			if (StringUtils.isNotBlank(priceRange.getMaxPrice().getFormattedValue())
					&& StringUtils.isNotBlank(priceRange.getMinPrice().getFormattedValue()))
			{
				//if priceMax equals to priceMin show real price
				formattedValue = StringUtils.equals(priceRange.getMinPrice().getFormattedValue(), priceRange.getMaxPrice()
						.getFormattedValue()) ? formattedValue : priceRange.getMinPrice().getFormattedValue() + " - "
						+ priceRange.getMaxPrice().getFormattedValue();
			}
		}
		return formattedValue;
	}

	public String getFirstVariantImage()
	{
		return firstVariantImage;
	}

	public void setFirstVariantImage(String firstVariantImage)
	{
		this.firstVariantImage = firstVariantImage;
	}

	public String getFirstVariantCode()
	{
		return firstVariantCode;
	}

	public void setFirstVariantCode(String firstVariantCode)
	{
		this.firstVariantCode = firstVariantCode;
	}

	public List<ProductVariant> getVariantMatrix()
	{
		return variantMatrix;
	}

	public void setVariantMatrix(List<ProductVariant> variantMatrix)
	{
		this.variantMatrix = variantMatrix;
	}

	public List<VariantCategory> getVariantCategories()
	{
		return categories;
	}

	public void setVariantCategories(List<VariantCategory> categories)
	{
		this.categories = categories;
	}


	public List<Price> getVolumePrices()
	{
		return volumePrices;
	}

	public void setVolumePrices(List<Price> volumePrices)
	{
		this.volumePrices = volumePrices;
	}


	public static class VariantCategory
	{

		private String code;
		private String url;

		public String getCode()
		{
			return code;
		}

		public void setCode(String code)
		{
			this.code = code;
		}

		public String getUrl()
		{
			return url;
		}

		public void setUrl(String url)
		{
			this.url = url;
		}



	}
}
