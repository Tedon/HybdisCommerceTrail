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

import android.app.Activity;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.utils.ProductUtils;
import com.hybris.mobile.lib.b2b.data.product.Price;
import com.hybris.mobile.lib.b2b.data.product.Product;


/**
 * Base adapter for catalog content
 */
public class ProductItemsAdapter extends ArrayAdapter<Product>
{

	// Products for the adapter
	protected List<Product> mProducts;
	protected ProductViewHolder currentSelectedViewHolder = null;

	public ProductItemsAdapter(Activity context, List<Product> values, int layoutResId)
	{
		super(context, layoutResId, values);
		this.mProducts = values;
	}

	@Override
	public Activity getContext()
	{
		return (Activity) super.getContext();
	}

	/**
	 * Return the product list
	 * 
	 * @return
	 */
	public List<Product> getProducts()
	{
		return mProducts;
	}

	public ProductViewHolder getCurrentSelectedViewHolder()
	{
		return currentSelectedViewHolder;
	}

	public void setCurrentSelectedViewHolder(ProductViewHolder currentSelectedViewHolder)
	{
		this.currentSelectedViewHolder = currentSelectedViewHolder;
	}


	@Override
	public int getCount()
	{
		return mProducts.size();
	}

	/**
	 * Contains all UI elements for Product to improve view display while scrolling
	 */
	static class ProductViewHolder
	{
		// Collpased View
		RelativeLayout collapsedLayout;
		LinearLayout productItemClickableLayoutCollapsed;
		RelativeLayout productItemButtonLayout;
		LinearLayout productItemAddQuantityLayout;
		LinearLayout productItemBlockNameCollapsedLayout;
		TextView productName;
		TextView productNo;
		TextView productPrice;
		TextView productAvailability;
		TextView productItemInStock;
		TextView productPriceTotal;
		ImageView productImageViewCartIcon;
		ImageView productImageViewExpandIcon;
		EditText quantityEditText;
		RelativeLayout productItemButtonCollpaseLayout;
		FrameLayout productItemMainLayoutCollapsedLayout;

		// Expanded view
		LinearLayout expandedLayout;
		LinearLayout productItemClickableLayoutExpanded;
		LinearLayout productItemBlockNameExpandedLayout;
		TextView productNameExpanded;
		TextView productNoExpanded;
		TextView productPriceExpanded;
		TextView productAvailabilityExpanded;
		TextView productPriceTotalExpanded;
		ImageView productImageViewCollpaseIcon;
		ImageView productImageViewCartIconExpanded;
		EditText quantityEditTextExpanded;
		RelativeLayout productItemButtonAddCartLayoutExpanded;

		// Spinners for variants
		Spinner productItemVariantSpinner1;
		Spinner productItemVariantSpinner2;
		Spinner productItemVariantSpinner3;

		// Product Images
		ImageView productImage;
		ProgressBar productImageLoading;
		ImageView productImageExpanded;
		ProgressBar productImageLoadingExpanded;
		ProgressBar productItemStockLevelLoadingExpanded;

		public ProductViewHolder(View view)
		{
			//Collpased View
			collapsedLayout = (RelativeLayout) view.findViewById(R.id.collapsed_layout);
			productItemClickableLayoutCollapsed = (LinearLayout) view.findViewById(R.id.product_item_clickable_layout_collapsed);
			productItemButtonLayout = (RelativeLayout) view.findViewById(R.id.product_item_button_layout);
			productItemAddQuantityLayout = (LinearLayout) view.findViewById(R.id.product_item_add_quantity_layout);
			productItemBlockNameCollapsedLayout = (LinearLayout) view.findViewById(R.id.product_item_block_name_collapsed);
			productName = (TextView) view.findViewById(R.id.product_item_name);
			productNo = (TextView) view.findViewById(R.id.product_item_no);
			productPrice = (TextView) view.findViewById(R.id.product_item_price);
			productAvailability = (TextView) view.findViewById(R.id.product_item_stock_level);
			productItemInStock = (TextView) view.findViewById(R.id.product_item_in_stock);
			productPriceTotal = (TextView) view.findViewById(R.id.product_item_price_total);
			productImageViewCartIcon = (ImageView) view.findViewById(R.id.product_item_button_cart_icon);
			productImageViewExpandIcon = (ImageView) view.findViewById(R.id.product_item_button_expand_icon);
			quantityEditText = (EditText) view.findViewById(R.id.product_item_add_quantity);
			productItemButtonCollpaseLayout = (RelativeLayout) view.findViewById(R.id.product_item_button_collpase_layout);
			productItemMainLayoutCollapsedLayout = (FrameLayout) view.findViewById(R.id.product_item_image_layout);

			//Expanded view
			expandedLayout = (LinearLayout) view.findViewById(R.id.expanded_layout);
			productItemClickableLayoutExpanded = (LinearLayout) view.findViewById(R.id.product_item_clickable_layout_expanded);
			productItemBlockNameExpandedLayout = (LinearLayout) view.findViewById(R.id.product_item_block_name_layout_expanded);
			productNameExpanded = (TextView) view.findViewById(R.id.product_item_name_expanded);
			productNoExpanded = (TextView) view.findViewById(R.id.product_item_no_expanded);
			productPriceExpanded = (TextView) view.findViewById(R.id.product_item_price_expanded);
			productAvailabilityExpanded = (TextView) view.findViewById(R.id.product_item_stock_level_expanded);
			productPriceTotalExpanded = (TextView) view.findViewById(R.id.product_item_price_total_expanded);
			productImageViewCollpaseIcon = (ImageView) view.findViewById(R.id.product_item_button_collapse_icon);
			productImageViewCartIconExpanded = (ImageView) view.findViewById(R.id.product_item_button_cart_icon_expanded);
			quantityEditTextExpanded = (EditText) view.findViewById(R.id.product_item_add_quantity_expanded);
			productItemButtonAddCartLayoutExpanded = (RelativeLayout) view
					.findViewById(R.id.product_item_button_add_cart_layout_expanded);

			productImageExpanded = (ImageView) view.findViewById(R.id.product_item_image_expanded);
			productImageLoadingExpanded = (ProgressBar) view.findViewById(R.id.product_item_image_loading_expanded);
			productItemStockLevelLoadingExpanded = (ProgressBar) view.findViewById(R.id.product_item_stock_level_loading_expanded);

			productImage = (ImageView) view.findViewById(R.id.product_item_image);
			productImageLoading = (ProgressBar) view.findViewById(R.id.product_item_image_loading);

			productItemVariantSpinner1 = (Spinner) view.findViewById(R.id.product_item_variant_spinner_1);
			productItemVariantSpinner2 = (Spinner) view.findViewById(R.id.product_item_variant_spinner_2);
			productItemVariantSpinner3 = (Spinner) view.findViewById(R.id.product_item_variant_spinner_3);

		}

		public EditText getQuantityEditText()
		{
			return quantityEditText;
		}

		public void setQuantityEditText(EditText quantityEditText)
		{
			this.quantityEditText = quantityEditText;
		}

		public EditText getQuantityEditTextExpanded()
		{
			return quantityEditTextExpanded;
		}

		public void setQuantityEditTextExpanded(EditText quantityEditTextExpanded)
		{
			this.quantityEditTextExpanded = quantityEditTextExpanded;
		}

		/**
		 * Collapse view
		 */
		public void collapse()
		{

			expandedLayout.setVisibility(View.GONE);
			collapsedLayout.setVisibility(View.VISIBLE);
		}

		/**
		 * Expand view
		 */
		public void expand()
		{
			expandedLayout.setVisibility(View.VISIBLE);
			collapsedLayout.setVisibility(View.GONE);
		}

		/**
		 * Change layout view when quantity is set to 0 otherwise stay enabled
		 */
		public void setAddCartButton()
		{
			boolean editable = (StringUtils.isNotBlank(quantityEditText.getText().toString()) && Integer.parseInt(quantityEditText
					.getText().toString()) > 0);

			boolean editableExpanded = (StringUtils.isNotBlank(quantityEditTextExpanded.getText().toString()) && Integer
					.parseInt(quantityEditTextExpanded.getText().toString()) > 0);

			productItemButtonLayout.setEnabled(editable);
			productImageViewCartIcon.setEnabled(editable);
			productImageViewCartIcon.setClickable(editable);

			productItemButtonAddCartLayoutExpanded.setEnabled(editableExpanded);
			productImageViewCartIconExpanded.setEnabled(editableExpanded);
			productImageViewCartIconExpanded.setClickable(editableExpanded);
		}

		/**
		 * TODO : NOW, Get currency from formatted value To remove it when currencySign is avalaible in the json
		 * 
		 * @param price
		 * @param quantity
		 * @return
		 */
		public String setTotalPrice(Price price, String quantity)
		{
			return StringUtils.substring(price.getFormattedValue(), 0, 1) + ProductUtils.calculateQuantityPrice(quantity, price);
		}


	}
}
