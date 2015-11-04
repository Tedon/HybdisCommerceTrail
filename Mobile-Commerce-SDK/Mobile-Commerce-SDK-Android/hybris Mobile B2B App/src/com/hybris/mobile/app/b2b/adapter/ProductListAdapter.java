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

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.app.Activity;
import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.Spinner;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.helper.CartHelper;
import com.hybris.mobile.app.b2b.helper.ProductHelper;
import com.hybris.mobile.app.b2b.utils.ProductUtils;
import com.hybris.mobile.app.b2b.utils.UIUtils;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.product.Product;
import com.hybris.mobile.lib.b2b.data.product.ProductVariant;
import com.hybris.mobile.lib.b2b.query.QueryProductDetails;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.ui.listener.SubmitListener;
import com.hybris.mobile.lib.ui.view.Alert;


/**
 * Adapter Product Item UI to display for each row
 */
public class ProductListAdapter extends ProductItemsAdapter
{
	public static final String TAG = ProductListAdapter.class.getCanonicalName();

	private View rowView = null;
	private int currentSelectedPosition = -1;
	private Product currentSelectedProduct;
	private String mRequestId;
	private boolean mTriggerSpinnerOnChange = false;
	private int mNbVariantLevels = 0;
	private int mNbVariantLevelsInstantiated = 0;

	public ProductListAdapter(Activity context, List<Product> values, String requestId)
	{
		super(context, values, R.layout.item_product_listview);
		this.mRequestId = requestId;
	}


	@Override
	public View getView(final int position, final View convertView, final ViewGroup parent)
	{

		if (convertView == null)
		{
			LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			rowView = inflater.inflate(R.layout.item_product_listview, parent, false);
			rowView.setTag(new ProductViewHolder(rowView));
		}
		else
		{
			rowView = convertView;
		}
		// When clicking outside a EditText, hide keyboard, remove focus and
		// reset to the default value
		// Clicking on the main view
		rowView.setOnTouchListener(new OnTouchListener()
		{

			@Override
			public boolean onTouch(View v, MotionEvent event)
			{
				UIUtils.hideKeyboard(getContext());
				v.performClick();
				return false;
			}
		});

		final ProductViewHolder viewHolder = (ProductViewHolder) rowView.getTag();

		if (currentSelectedPosition == position)
		{
			createExpandedView(viewHolder, position);
		}
		else
		{

			// Populate name and code for a product when row collapsed
			viewHolder.productName.setText(mProducts.get(position).getName());
			viewHolder.productNo.setText(mProducts.get(position).getCode());
			viewHolder.productPrice.setText(mProducts.get(position).getPriceRangeFormattedValue());
			viewHolder.quantityEditText.setText(getContext().getString(R.string.default_qty));
			viewHolder.productPrice.setText(mProducts.get(position).getPriceRangeFormattedValue());

			// Loading the product image
			loadProductImage(mProducts.get(position).getFirstVariantImage(), viewHolder.productImage,
					viewHolder.productImageLoading, mProducts.get(position).getCode());
			viewHolder.collapse();

			if (mProducts.get(position).isMultidimensional())
			{
				// Show arrow down with variants
				viewHolder.productPriceTotal.setVisibility(View.GONE);
				viewHolder.productImageViewCartIcon.setVisibility(View.GONE);
				viewHolder.productImageViewExpandIcon.setVisibility(View.VISIBLE);
				viewHolder.productItemAddQuantityLayout.setVisibility(View.INVISIBLE);
				viewHolder.quantityEditText.setVisibility(View.INVISIBLE);
				viewHolder.productAvailability.setText("");
				viewHolder.productItemInStock.setVisibility(View.INVISIBLE);

				/**
				 * Gray out button
				 */
				viewHolder.setAddCartButton();
			}
			else
			{
				// Show cart icon without variants
				viewHolder.productItemAddQuantityLayout.setVisibility(View.VISIBLE);
				viewHolder.productPriceTotal.setVisibility(View.VISIBLE);
				viewHolder.productPriceTotal.setText(viewHolder.setTotalPrice(mProducts.get(position).getPrice(),
						viewHolder.quantityEditText.getText().toString()));
				viewHolder.productImageViewCartIcon.setVisibility(View.VISIBLE);
				viewHolder.productImageViewExpandIcon.setVisibility(View.GONE);
				viewHolder.quantityEditText.setEnabled(true);
				viewHolder.quantityEditText.setVisibility(View.VISIBLE);
				viewHolder.productAvailability.setText(mProducts.get(position).getStock().getStockLevel() + "");
				viewHolder.productItemInStock.setVisibility(View.VISIBLE);

				viewHolder.setAddCartButton();

				if (mProducts.get(position).isLowStock() || mProducts.get(position).isOutOfStock())
				{
					viewHolder.productAvailability.setTextColor(getContext().getResources().getColor(R.color.product_item_low_stock));
					viewHolder.productItemInStock.setTextColor(getContext().getResources().getColor(R.color.product_item_low_stock));
					viewHolder.productAvailability.setContentDescription(getContext().getString(R.string.product_item_low_stock));

					if (mProducts.get(position).isOutOfStock())
					{
						viewHolder.quantityEditText.setEnabled(false);
						viewHolder.quantityEditText.setText("");

					}

				}

				if (mProducts.get(position).isInStock())
				{
					viewHolder.productAvailability.setText("");
					viewHolder.productItemInStock.setTextColor(getContext().getResources().getColor(R.color.product_item_in_stock));
				}
			}

		}

		/**
		 * Product item row is collapsed and user click the arrow down icon to expand
		 */
		viewHolder.productImageViewExpandIcon.setOnClickListener(new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{
				// Expanded
				QueryProductDetails queryProductDetails = new QueryProductDetails();
				queryProductDetails.setCode(StringUtils.isNotBlank(mProducts.get(position).getFirstVariantCode()) ? mProducts.get(
						position).getFirstVariantCode() : mProducts.get(position).getCode());

				/**
				 * Display product detail info
				 */
				B2BApplication.getContentServiceHelper().getProductDetails(new ResponseReceiver<Product>()
				{
					@Override
					public void onResponse(Response<Product> response)
					{
						currentSelectedProduct = response.getData();

						if (currentSelectedViewHolder != null)
						{

							currentSelectedViewHolder.collapse();
						}

						viewHolder.collapse();

						if (currentSelectedProduct != null)
						{
							currentSelectedPosition = position;
							currentSelectedViewHolder = viewHolder;
							createExpandedView(viewHolder, position);
						}
					}

					@Override
					public void onError(Response<DataError> response)
					{
						Alert.showCritical(getContext(), response.getData().getErrorMessage().getMessage());
					}
				}, mRequestId, queryProductDetails, false, null, new OnRequestListener()
				{

					@Override
					public void beforeRequest()
					{
						UIUtils.showLoadingActionBar(getContext(), true);
					}

					@Override
					public void afterRequest()
					{
						UIUtils.showLoadingActionBar(getContext(), false);
					}
				});

			}
		});

		/**
		 * Detect when text is changed
		 */
		viewHolder.quantityEditText.addTextChangedListener(new TextWatcher()
		{

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after)
			{
			}

			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count)
			{

				try
				{

					if (mProducts.size() > position && mProducts.get(position) != null)
					{
						if (mProducts.get(position).getPrice() != null)
						{
							viewHolder.productPriceTotal.setText(viewHolder.setTotalPrice(mProducts.get(position).getPrice(),
									viewHolder.quantityEditText.getText().toString()));
						}
					}
					viewHolder.setAddCartButton();
				}
				catch (NumberFormatException e)
				{
					Log.e(TAG, e.getLocalizedMessage());
				}

			}

			@Override
			public void afterTextChanged(Editable s)
			{
			}
		});

		/**
		 * Detect when text is changed
		 */
		viewHolder.quantityEditTextExpanded.addTextChangedListener(new TextWatcher()
		{

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after)
			{
			}

			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count)
			{

				try
				{
					if (mProducts.size() > position && mProducts.get(position).getPrice() != null)
					{
						viewHolder.productPriceTotalExpanded.setText(viewHolder.setTotalPrice(currentSelectedProduct.getPrice(),
								viewHolder.quantityEditTextExpanded.getText().toString()));


					}
					viewHolder.setAddCartButton();
				}
				catch (NumberFormatException e)
				{
					Log.e(TAG, e.getLocalizedMessage());
				}

			}

			@Override
			public void afterTextChanged(Editable s)
			{
			}
		});

		/**
		 * Add to cart when user click on cartIcon in Product item collapsed row
		 */
		viewHolder.productImageViewCartIcon.setOnClickListener(new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{
				addToCart(mProducts.get(position).getCode(), viewHolder.quantityEditText.getText().toString());
				viewHolder.quantityEditText.setText(getContext().getString(R.string.default_qty));
			}
		});

		viewHolder.quantityEditText.setOnEditorActionListener(new SubmitListener()
		{

			@Override
			public void onSubmitAction()
			{
				addToCart(mProducts.get(position).getCode(), viewHolder.quantityEditText.getText().toString());
				viewHolder.quantityEditText.setText(getContext().getString(R.string.default_qty));
			}
		});


		/**
		 * Product item row is expanded and user click the arrow up icon to collapse
		 */
		viewHolder.productItemButtonCollpaseLayout.setOnClickListener(new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{

				// collapsed
				viewHolder.collapse();

			}
		});

		/**
		 * Product item row is collapsed and user click on the main part of the row to navigate to the product detail page
		 */
		viewHolder.productItemClickableLayoutCollapsed.setOnClickListener(new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{
				ProductHelper.redirectToProductDetail(getContext(), StringUtils.isNotBlank(mProducts.get(position)
						.getFirstVariantCode()) ? mProducts.get(position).getFirstVariantCode() : mProducts.get(position).getCode());
			}
		});

		/**
		 * Product item row is collapsed and user click on the main part of the row to navigate to the product detail page
		 */
		viewHolder.productItemClickableLayoutExpanded.setOnClickListener(new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{
				ProductHelper.redirectToProductDetail(getContext(), StringUtils.isNotBlank(currentSelectedProduct
						.getFirstVariantCode()) ? currentSelectedProduct.getFirstVariantCode() : currentSelectedProduct.getCode());
			}
		});

		return rowView;
	}

	/**
	 * Show image Product from URL
	 * 
	 * @param imageUrl
	 *           image url
	 * @param imageView
	 * @param progressBar
	 * @param productCode
	 *           product code to find
	 */
	private void loadProductImage(String imageUrl, final ImageView imageView, final ProgressBar progressBar, String productCode)
	{

		// Loading the product image
		if (StringUtils.isNotBlank(imageUrl))
		{

			B2BApplication.getContentServiceHelper().loadImage(imageUrl, "product_list_image_" + productCode, imageView, 0, 0, true,
					new OnRequestListener()
					{

						@Override
						public void beforeRequest()
						{
							imageView.setImageResource(android.R.color.transparent);
							imageView.setVisibility(View.GONE);
							progressBar.setVisibility(View.VISIBLE);
						}

						@Override
						public void afterRequest()
						{
							imageView.setVisibility(View.VISIBLE);
						}
					}, true);
		}

	}

	/**
	 * 
	 * @param viewHolder
	 * @param position
	 */
	private void createExpandedView(ProductViewHolder viewHolder, int position)
	{
		// By default the on change is not triggered on the variants spinner EXCEPT for the first one (prevent the call of onchange on each spinner)
		mTriggerSpinnerOnChange = false;
		mNbVariantLevelsInstantiated = 0;

		viewHolder.productNameExpanded.setText(currentSelectedProduct.getName());
		viewHolder.productNoExpanded.setText(currentSelectedProduct.getCode());
		viewHolder.productPriceExpanded.setText(currentSelectedProduct.getPriceRangeFormattedValue());

		viewHolder.productPriceTotalExpanded.setText(viewHolder.setTotalPrice(currentSelectedProduct.getPrice(),
				viewHolder.quantityEditTextExpanded.getText().toString()));

		if (currentSelectedProduct.isOutOfStock())
		{

			viewHolder.quantityEditTextExpanded.setEnabled(false);
			viewHolder.quantityEditTextExpanded.setText("");
			viewHolder.productAvailabilityExpanded.setText(currentSelectedProduct.getStock().getStockLevel() + "");
		}
		else
		{
			viewHolder.productAvailabilityExpanded.setText(currentSelectedProduct.getStock().getStockLevel() + "");
		}

		// Loading the product image for expanded view
		loadProductImage(currentSelectedProduct.getImageThumbmailUrl(), viewHolder.productImageExpanded,
				viewHolder.productImageLoadingExpanded, currentSelectedProduct.getCode());

		// Populate the spinner
		List<Spinner> spinners = new ArrayList<Spinner>();
		spinners.add(viewHolder.productItemVariantSpinner1);
		spinners.add(viewHolder.productItemVariantSpinner2);
		spinners.add(viewHolder.productItemVariantSpinner3);
		mNbVariantLevels = ProductHelper.populateVariant(getContext(), spinners, currentSelectedProduct);

		viewHolder.productItemVariantSpinner2.setOnItemSelectedListener(productDetailVariantSpinnerListener);
		viewHolder.productItemVariantSpinner3.setOnItemSelectedListener(productDetailVariantSpinnerListener);
		viewHolder.productItemVariantSpinner1.setOnItemSelectedListener(productDetailVariantSpinnerListener);

		viewHolder.setAddCartButton();

		viewHolder.expand();

	}

	/**
	 * Add to cart
	 * 
	 * @param code
	 *           : product code
	 * @param qty
	 *           : quantity to added
	 */
	private void addToCart(String code, String qty)
	{
		try
		{
			CartHelper.addToCart(getContext(), null, null, code, Integer.parseInt(qty), null, null);
		}
		catch (NumberFormatException e)
		{
			Log.e(TAG, e.getLocalizedMessage());
		}
	}

	/**
	 * Populate the product
	 * 
	 * @param updateImages
	 */
	private void populateProduct(final Product product)
	{
		if (product != null)
		{
			/**
			 * Populate the view with data from response and associate it to the right element in the view
			 */
			currentSelectedViewHolder.productNameExpanded.setText(product.getName());
			currentSelectedViewHolder.productNoExpanded.setText(product.getCode());

			if (product.getStock() != null)
			{
				currentSelectedViewHolder.productAvailabilityExpanded.setVisibility(View.VISIBLE);
				if (product.isLowStock() || product.isOutOfStock())
				{
					currentSelectedViewHolder.productAvailabilityExpanded.setTextColor(getContext().getResources().getColor(
							R.color.product_item_low_stock));
					currentSelectedViewHolder.productAvailabilityExpanded.setContentDescription(getContext().getString(
							R.string.product_item_low_stock));

					if (product.isOutOfStock())
					{
						currentSelectedViewHolder.quantityEditTextExpanded.setEnabled(false);
						currentSelectedViewHolder.quantityEditTextExpanded.setText("");
						currentSelectedViewHolder.productAvailabilityExpanded.setText(product.getStock().getStockLevel() + "\n"
								+ getContext().getResources().getString(R.string.product_detail_in_stock));

					}

				}

				if (product.isInStock())
				{
					currentSelectedViewHolder.productAvailabilityExpanded.setText(product.getStock().getStockLevel() + "\n"
							+ getContext().getResources().getString(R.string.product_detail_in_stock));
					currentSelectedViewHolder.productAvailabilityExpanded.setTextColor(getContext().getResources().getColor(
							R.color.product_item_in_stock));
				}


			}
			else
			{
				Log.d(TAG, "Stock is null");
			}

			if (product.getPrice() != null)
			{
				currentSelectedViewHolder.productPriceExpanded.setText((product.getVolumePrices() != null) ? product
						.getPriceRangeFormattedValue() + " | " : product.getPriceRangeFormattedValue());

				// Set the price with the default total value
				currentSelectedViewHolder.productPriceTotalExpanded.setText((StringUtils.substring(product.getPrice()
						.getFormattedValue(), 0, 1) + ProductUtils.calculateQuantityPrice(
						currentSelectedViewHolder.quantityEditTextExpanded.getText().toString(),
						(product.getVolumePrices() != null) ? ProductUtils.findVolumePrice(
								currentSelectedViewHolder.quantityEditTextExpanded.getText().toString(), product.getVolumePrices())
								: product.getPrice())));
			}
			else
			{
				Log.d(TAG, "Price is null");
			}



			// Loading the product image for expanded view
			loadProductImage(currentSelectedProduct.getImageThumbmailUrl(), currentSelectedViewHolder.productImageExpanded,
					currentSelectedViewHolder.productImageLoadingExpanded, currentSelectedProduct.getCode());

			/**
			 * Add to cart when user click on cartIcon in Product item expanded row
			 */
			currentSelectedViewHolder.productImageViewCartIconExpanded.setOnClickListener(new OnClickListener()
			{
				@Override
				public void onClick(View v)
				{
					addToCart(currentSelectedProduct.getCode(), currentSelectedViewHolder.quantityEditTextExpanded.getText()
							.toString());
					currentSelectedViewHolder.quantityEditTextExpanded.setText(getContext().getString(R.string.default_qty));
				}
			});

			currentSelectedViewHolder.quantityEditTextExpanded.setOnEditorActionListener(new SubmitListener()
			{

				@Override
				public void onSubmitAction()
				{
					// Perform action on key press				
					addToCart(currentSelectedProduct.getCode(), currentSelectedViewHolder.quantityEditTextExpanded.getText()
							.toString());
					currentSelectedViewHolder.quantityEditTextExpanded.setText(getContext().getString(R.string.default_qty));

				}
			});
		}
	}

	/**
	 * Get variant from dropdown and display info in product details page
	 * 
	 * @param pSelectedVariant
	 */
	private void selectVariant(ProductVariant pSelectedVariant)
	{
		QueryProductDetails queryProductDetails = new QueryProductDetails();
		queryProductDetails.setCode(pSelectedVariant.getVariantOption().getCode());

		/**
		 * Display product detail info
		 */
		B2BApplication.getContentServiceHelper().getProductDetails(new ResponseReceiver<Product>()
		{

			@Override
			public void onResponse(Response<Product> response)
			{
				currentSelectedProduct = response.getData();
				if (currentSelectedProduct != null)
				{
					populateProduct(currentSelectedProduct);
				}
			}

			@Override
			public void onError(Response<DataError> response)
			{
				Alert.showCritical(getContext(), response.getData().getErrorMessage().getMessage());
			}
		}, mRequestId, queryProductDetails, false, null, new OnRequestListener()
		{

			@Override
			public void beforeRequest()
			{
				// Expanded
				currentSelectedViewHolder.productImageLoadingExpanded.setVisibility(View.VISIBLE);
				currentSelectedViewHolder.productItemStockLevelLoadingExpanded.setVisibility(View.VISIBLE);
				currentSelectedViewHolder.productImageExpanded.setVisibility(View.INVISIBLE);
				currentSelectedViewHolder.productAvailabilityExpanded.setVisibility(View.INVISIBLE);
				UIUtils.showLoadingActionBar(getContext(), true);
			}

			@Override
			public void afterRequest()
			{
				currentSelectedViewHolder.productImageLoadingExpanded.setVisibility(View.INVISIBLE);
				currentSelectedViewHolder.productItemStockLevelLoadingExpanded.setVisibility(View.INVISIBLE);
				currentSelectedViewHolder.productImageExpanded.setVisibility(View.VISIBLE);
				currentSelectedViewHolder.productAvailabilityExpanded.setVisibility(View.VISIBLE);
				currentSelectedViewHolder.productImageLoading.setVisibility(View.INVISIBLE);
				UIUtils.showLoadingActionBar(getContext(), false);
			}
		});

	}

	/**
	 * Class to handle User interaction with multi-dimensional spinner
	 * 
	 */
	public OnItemSelectedListener productDetailVariantSpinnerListener = new OnItemSelectedListener()
	{
		@Override
		public void onItemSelected(AdapterView<?> parent, View view, int position, long id)
		{
			// Workaround to activate the onchange listener only after having instantiated the latest spinner
			mNbVariantLevelsInstantiated++;
			if (mNbVariantLevelsInstantiated == mNbVariantLevels)
			{
				mTriggerSpinnerOnChange = true;
			}

			if (parent.getItemAtPosition(position) != null && mTriggerSpinnerOnChange)
			{
				ProductVariant mSelectedVariant = (ProductVariant) parent.getItemAtPosition(position);
				selectVariant(mSelectedVariant);

				Spinner spinnerToUpdate = null;

				switch (parent.getId())
				{
					case R.id.product_item_variant_spinner_1:
						spinnerToUpdate = currentSelectedViewHolder.productItemVariantSpinner2;
						break;

					case R.id.product_item_variant_spinner_2:
						spinnerToUpdate = currentSelectedViewHolder.productItemVariantSpinner3;
						break;

					default:
						break;
				}

				ProductHelper.populateSpinner(getContext(), spinnerToUpdate, mSelectedVariant.getElements(), 0);
			}

		}

		@Override
		public void onNothingSelected(AdapterView<?> parent)
		{
		}
	};

}
