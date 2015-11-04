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

import java.util.List;

import org.apache.commons.lang3.StringUtils;


public class ProductVariant
{
	private boolean isLeaf;
	private ParentVariantCategory parentVariantCategory;
	private VariantValueCategory variantValueCategory;
	private List<ProductVariant> elements;
	private ProductVariantOption variantOption;
	private int variantDimensionsNumber;

	public static class ParentVariantCategory
	{

		private boolean hasImage;
		private String name;

		public boolean isHasImage()
		{
			return hasImage;
		}

		public void setHasImage(boolean hasImage)
		{
			this.hasImage = hasImage;
		}

		public String getName()
		{
			return name;
		}

		public void setName(String name)
		{
			this.name = name;
		}

	}

	public static class VariantValueCategory
	{
		private String code;
		private int sequence;
		private String name;

		//TODO : change for the real code
		public String getCode()
		{
			if (StringUtils.isBlank(code))
			{
				code = "B2B_" + StringUtils.replaceChars(name, '.', '_');
			}
			return code;
		}

		public void setCode(String code)
		{
			if (StringUtils.isBlank(code))
			{
				code = "B2B_" + StringUtils.replaceChars(name, '.', '_');
			}
			this.code = code;
		}

		public int getSequence()
		{
			return sequence;
		}

		public void setSequence(int sequence)
		{
			this.sequence = sequence;
		}


		public String getName()
		{
			return name;
		}

		public void setName(String name)
		{
			this.name = name;
		}
	}

	public VariantValueCategory getVariantValueCategory()
	{
		return variantValueCategory;
	}

	public void setVariantValueCategory(VariantValueCategory variantValueCategory)
	{
		this.variantValueCategory = variantValueCategory;
	}

	public ParentVariantCategory getParentVariantCategory()
	{
		return parentVariantCategory;
	}

	public void setParentVariantCategory(ParentVariantCategory parentVariantCategory)
	{
		this.parentVariantCategory = parentVariantCategory;
	}

	public List<ProductVariant> getElements()
	{
		return elements;
	}

	public void setElements(List<ProductVariant> elements)
	{
		this.elements = elements;
	}

	public boolean isLeaf()
	{
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf)
	{
		this.isLeaf = isLeaf;
	}

	public ProductVariantOption getVariantOption()
	{
		return variantOption;
	}

	public void setVariantOption(ProductVariantOption variantOption)
	{
		this.variantOption = variantOption;
	}

	public int getVariantDimensionsNumber()
	{
		if (!this.elements.isEmpty())
		{
			variantDimensionsNumber = 1 + this.elements.get(0).getVariantDimensionsNumber();
		}
		else
		{
			variantDimensionsNumber = 1;
		}
		return variantDimensionsNumber;
	}

}
