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
package com.hybris.mobile.app.b2b.helper;

import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.widget.Spinner;

import com.hybris.mobile.app.b2b.IntentConstants;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.activity.ProductDetailActivity;
import com.hybris.mobile.app.b2b.adapter.VariantAdapter;
import com.hybris.mobile.lib.b2b.data.product.Product;
import com.hybris.mobile.lib.b2b.data.product.Product.VariantCategory;
import com.hybris.mobile.lib.b2b.data.product.ProductVariant;


/**
 * Helper for products
 */
public class ProductHelper
{
	public static final String TAG = ProductHelper.class.getCanonicalName();

	/**
	 * Redirect to the product details page
	 * 
	 * @param context
	 * @param productCode
	 */
	public static void redirectToProductDetail(Context context, String productCode)
	{
		if (StringUtils.isNotBlank(productCode))
		{
			Intent intentProductDetail = new Intent(context, ProductDetailActivity.class);
			intentProductDetail.putExtra(IntentConstants.PRODUCT_CODE, productCode);
			context.startActivity(intentProductDetail);
		}
	}

	/**
	 * populate the spinner with variants otherwise hide Maximum supported Spinner is 3
	 */
	public static int populateVariant(Context context, List<Spinner> spinners, Product product)
	{
		int nbLevels = 0;

		if (product != null)
		{
			if (product.getVariantMatrix() != null && !product.getVariantMatrix().isEmpty())
			{

				// Get the variant position
				int position = findVariantPosition(product.getVariantCategories(), product.getVariantMatrix());
				populateSpinner(context, spinners.get(0), product.getVariantMatrix(), position);

				nbLevels = 1;

				if (product.getVariantMatrix() != null && product.getVariantMatrix().size() > position)
				{
					// Get the childs at the variant position
					ProductVariant variant1 = product.getVariantMatrix().get(position);

					if (variant1.getElements() != null && !variant1.getElements().isEmpty())
					{
						nbLevels = 2;

						// Get the variant position
						position = findVariantPosition(product.getVariantCategories(), variant1.getElements());
						populateSpinner(context, spinners.get(1), variant1.getElements(),
								findVariantPosition(product.getVariantCategories(), variant1.getElements()));

						if (variant1.getElements() != null && variant1.getElements().size() > position)
						{
							// Get the childs at the variant position
							ProductVariant variant2 = variant1.getElements().get(position);

							if (variant2.getElements() != null && !variant2.getElements().isEmpty())
							{
								nbLevels = 3;

								populateSpinner(context, spinners.get(2), variant2.getElements(),
										findVariantPosition(product.getVariantCategories(), variant2.getElements()));
							}

						}

					}
				}

			}
		}

		return nbLevels;

	}


	/**
	 * Fill Spinner list with arraylist of variantMatrixElement
	 * 
	 * @param spinner
	 * @param elements
	 */
	public static void populateSpinner(Context context, Spinner spinner, List<ProductVariant> variants, int position)
	{
		if (spinner != null && variants != null && !variants.isEmpty())
		{
			VariantAdapter mVariantAdapter = new VariantAdapter(context, R.layout.item_product_variant, variants);
			spinner.setAdapter(mVariantAdapter);
			spinner.setPrompt(context.getString(R.string.choose_variant, variants.get(0).getParentVariantCategory().getName()));
			spinner.setVisibility(View.VISIBLE);
			spinner.setSelection(position);
		}
	}

	/**
	 * Use variantValueCategory code to find the default variant value with the category code
	 * 
	 * @return default variant position
	 */
	public static int findVariantPosition(List<VariantCategory> categories, List<ProductVariant> variants)
	{
		int position = 0;
		if (categories != null && variants != null)
		{
			for (VariantCategory category : categories)
			{
				position = 0;
				for (ProductVariant variant : variants)
				{
					if (StringUtils.equals(category.getCode(), variant.getVariantValueCategory().getCode()))
					{
						return position;
					}
					position++;
				}
			}
		}
		return position;
	}
}
