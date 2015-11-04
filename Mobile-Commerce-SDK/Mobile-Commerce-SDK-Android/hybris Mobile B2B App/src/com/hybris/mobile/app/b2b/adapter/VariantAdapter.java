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
package com.hybris.mobile.app.b2b.adapter;

import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.lib.b2b.data.product.ProductVariant;
import com.hybris.mobile.lib.http.listener.OnRequestListener;


/**
 * Adapter for the variant for Multi-Dimensional Products for Spinner
 * 
 * @author Anoulong.Chanthavong
 * 
 */
public class VariantAdapter extends ArrayAdapter<ProductVariant>
{
	private static final String TAG = VariantAdapter.class.getCanonicalName();

	private List<ProductVariant> mProductVariant;

	public VariantAdapter(Context context, int textViewResourceId, List<ProductVariant> productVariants)
	{
		super(context, textViewResourceId, productVariants);
		this.mProductVariant = productVariants;
	}


	@Override
	public View getDropDownView(int position, View convertView, ViewGroup parent)
	{
		return getCustomView(position, convertView, parent);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent)
	{
		return getCustomView(position, convertView, parent);
	}


	@Override
	public int getCount()
	{
		return mProductVariant.size();
	}


	/**
	 * Create the view for spinner item
	 * 
	 * @param position
	 * @param convertView
	 * @param parent
	 * @return
	 */
	public View getCustomView(int position, View convertView, ViewGroup parent)
	{

		View rowView = null;

		if (convertView == null)
		{
			LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			rowView = inflater.inflate(R.layout.item_product_variant, parent, false);
		}
		else
		{
			rowView = convertView;
		}

		ProductVariant productVariant = mProductVariant.get(position);

		TextView productVariantName = (TextView) rowView.findViewById(R.id.product_variant_name);
		final ImageView productVariantImage = (ImageView) rowView.findViewById(R.id.product_variant_image);
		final ProgressBar productVariantProgressBar = (ProgressBar) rowView.findViewById(R.id.product_variant_image_loading);

		productVariantName.setText(productVariant.getVariantValueCategory().getName());

		if (productVariant.getParentVariantCategory().isHasImage())
		{
			if (StringUtils.isNotBlank(productVariant.getVariantOption().getImageThumbmailUrl()))
			{

				B2BApplication.getContentServiceHelper().loadImage(productVariant.getVariantOption().getImageThumbmailUrl(), null,
						productVariantImage, 0, 0, true, new OnRequestListener()
						{

							@Override
							public void beforeRequest()
							{
								productVariantImage.setImageResource(android.R.color.transparent);
								productVariantImage.setVisibility(View.GONE);
								productVariantProgressBar.setVisibility(View.VISIBLE);
							}

							@Override
							public void afterRequest()
							{
								productVariantImage.setVisibility(View.VISIBLE);
								productVariantProgressBar.setVisibility(View.GONE);
							}
						}, true);
			}
		}

		return rowView;
	}
}
