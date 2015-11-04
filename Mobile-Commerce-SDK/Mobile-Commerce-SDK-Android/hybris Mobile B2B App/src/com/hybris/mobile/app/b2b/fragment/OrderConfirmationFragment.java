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
package com.hybris.mobile.app.b2b.fragment;

import java.util.ArrayList;

import org.apache.commons.lang3.StringUtils;

import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TableRow;
import android.widget.TextView;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.IntentConstants;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.activity.CatalogActivity;
import com.hybris.mobile.app.b2b.adapter.OrderProductListAdapter;
import com.hybris.mobile.app.b2b.utils.UIUtils;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.Promotion;
import com.hybris.mobile.lib.b2b.data.PromotionEntry;
import com.hybris.mobile.lib.b2b.data.order.Order;
import com.hybris.mobile.lib.b2b.data.order.OrderProduct;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.http.utils.RequestUtils;
import com.hybris.mobile.lib.ui.view.Alert;


/**
 * Container that handle the details information for a specific order
 * 
 */
public class OrderConfirmationFragment extends Fragment implements ResponseReceiver<Order>
{
	private String mOrderRequestId = RequestUtils.generateUniqueRequestId();
	private TextView mOrderConfirmNumber;
	private TextView mOrderConfirmEmail;
	private TextView mOrderConfirmDeliveryAddress;
	private TextView mOrderConfirmDeliveryMode;
	private OrderProductListAdapter mOrderProductListAdapter;

	private LinearLayout mOrderSummaryItemsLayout;
	private TextView mOrderSummaryItems;
	private TextView mOrderSummarySubtotal;
	private TextView mOrderSummarySavings;
	private TextView mOrderSummaryTax;
	private TextView mOrderSummaryShipping;
	private TextView mOrderSummaryTotal;
	private TextView mOrderSummaryPromotion;
	private TableRow mOrderSummarySavingsRow;

	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
	{
		return inflater.inflate(R.layout.fragment_order_confirmation, container, false);
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState)
	{
		super.onActivityCreated(savedInstanceState);

		mOrderConfirmNumber = (TextView) getView().findViewById(R.id.order_confirm_number_text);
		mOrderConfirmEmail = (TextView) getView().findViewById(R.id.order_confirm_email);
		mOrderConfirmDeliveryAddress = (TextView) getView().findViewById(R.id.order_confirm_delivery_address_text);
		mOrderConfirmDeliveryMode = (TextView) getView().findViewById(R.id.order_confirm_delivery_method_text);

		// order summary
		mOrderSummaryItemsLayout = (LinearLayout) getView().findViewById(R.id.order_summary_items_layout);
		mOrderSummaryItems = (TextView) getView().findViewById(R.id.order_summary_items);
		mOrderSummarySubtotal = (TextView) getView().findViewById(R.id.order_summary_subtotal);
		mOrderSummarySavings = (TextView) getView().findViewById(R.id.order_summary_savings);
		mOrderSummaryTax = (TextView) getView().findViewById(R.id.order_summary_tax);
		mOrderSummaryShipping = (TextView) getView().findViewById(R.id.order_summary_shipping);
		mOrderSummaryTotal = (TextView) getView().findViewById(R.id.order_summary_total);
		mOrderSummaryPromotion = (TextView) getView().findViewById(R.id.order_summary_promotion);
		mOrderSummarySavingsRow = (TableRow) getView().findViewById(R.id.order_summary_savings_row);

		// Product list
		ListView productList = (ListView) getActivity().findViewById(R.id.order_products_list);
		mOrderProductListAdapter = new OrderProductListAdapter(getActivity(), new ArrayList<OrderProduct>());
		productList.setAdapter(mOrderProductListAdapter);

		getView().findViewById(R.id.order_confirm_continue_shopping_button).setOnClickListener(
				orderConfirmContinueShoppingButtonListener);

		// Getting the order
		B2BApplication.getContentServiceHelper().getOrder(this, mOrderRequestId,
				getActivity().getIntent().getStringExtra(IntentConstants.ORDER_CODE), false, null, new OnRequestListener()
				{

					@Override
					public void beforeRequest()
					{
						UIUtils.showLoadingActionBar(getActivity(), true);
					}

					@Override
					public void afterRequest()
					{
						UIUtils.showLoadingActionBar(getActivity(), false);
					}
				});
	}

	@Override
	public void onResponse(Response<Order> response)
	{
		populateOrder(response.getData());
	}

	@Override
	public void onError(Response<DataError> response)
	{
		Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
	}

	private void populateOrder(Order order)
	{
		if (order != null)
		{

			if (StringUtils.isNotBlank(order.getCode()))
			{

				mOrderConfirmNumber.setText(getString(R.string.order_confirmation_number, order.getCode()));
			}

			// Display user email and billing address
			if (order.getUser() != null && StringUtils.isNotBlank(order.getUser().getUid()))
			{
				mOrderConfirmEmail.setText(getString(R.string.order_confirmation_detail, order.getUser().getUid()));

			}

			if (order.getDeliveryAddress() != null && StringUtils.isNotBlank(order.getDeliveryAddress().getFormattedAddress()))
			{
				mOrderConfirmDeliveryAddress.setText(order.getDeliveryAddress().getFormattedAddress());
			}

			// Display delivery method
			if (order.getDeliveryMode() != null)
			{

				mOrderConfirmDeliveryMode.setText(order.getDeliveryMode().getName() + " - "
						+ order.getDeliveryMode().getDescription() + " - "
						+ order.getDeliveryMode().getDeliveryCost().getFormattedValue());
			}

			if (order.getAppliedProductPromotions() != null && !order.getAppliedProductPromotions().isEmpty())
			{
				for (Promotion productPromotion : order.getAppliedProductPromotions())
				{
					if (productPromotion.getConsumedEntries() != null && !productPromotion.getConsumedEntries().isEmpty())
					{
						for (PromotionEntry promotionEntry : productPromotion.getConsumedEntries())
						{
							for (OrderProduct orderProduct : order.getDeliveryOrderGroups().get(0).getEntries())
							{
								if (promotionEntry.getOrderEntryNumber() == orderProduct.getEntryNumber())
								{
									if (StringUtils.isNotBlank(productPromotion.getDescription()))
									{
										orderProduct.setPromotion(productPromotion);
									}
								}
							}

						}
					}
				}
			}

			// fill order summary
			createOrderSummary(order);

			mOrderProductListAdapter.clear();
			mOrderProductListAdapter.addAll(order.getDeliveryOrderGroups().get(0).getEntries());

			// Updating the list
			mOrderProductListAdapter.notifyDataSetChanged();
		}
	}

	/**
	 * Continue shopping : browse to the catalog
	 * 
	 */
	public OnClickListener orderConfirmContinueShoppingButtonListener = new OnClickListener()
	{

		@Override
		public void onClick(View v)
		{
			startActivity(new Intent(getActivity(), CatalogActivity.class));
		}

	};

	/**
	 * Populate the order summary
	 * 
	 * @param order
	 */
	public void createOrderSummary(Order order)
	{
		if (order != null)
		{

			// Display total price
			if (order.getTotalPrice() != null)
			{
				mOrderSummaryTotal.setText(order.getTotalPrice().getFormattedValue());
			}

			// Display subtotal price
			if (order.getSubTotal() != null)
			{
				mOrderSummarySubtotal.setText(order.getSubTotal().getFormattedValue());
			}

			// Display tax price
			if (order.getTotalTax() != null)
			{
				mOrderSummaryTax.setText(order.getTotalTax().getFormattedValue());
			}

			// Display delivery method cost
			if (order.getDeliveryCost() != null)
			{
				mOrderSummaryShipping.setText(order.getDeliveryCost().getFormattedValue());
			}

			if (order.getAppliedOrderPromotions() != null && !order.getAppliedOrderPromotions().isEmpty())
			{
				if (StringUtils.isNotBlank(order.getOrderDiscounts().getFormattedValue()))
				{
					mOrderSummarySavingsRow.setVisibility(View.VISIBLE);
					mOrderSummarySavings.setText(order.getOrderDiscounts().getFormattedValue());
				}
			}


			if (order.getAppliedOrderPromotions() != null || order.getAppliedProductPromotions() != null)
			{
				if (order.getAppliedProductPromotions() != null && !order.getAppliedProductPromotions().isEmpty())
				{
					mOrderSummaryPromotion.setVisibility(View.VISIBLE);
					// Nb order Promotion
					StringBuffer promotion = new StringBuffer();

					if (order.getAppliedOrderPromotions() != null && !order.getAppliedOrderPromotions().isEmpty())
					{
						for (Promotion orderPromotion : order.getAppliedOrderPromotions())
						{
							promotion.append(orderPromotion.getDescription() + "\n");
						}
					}

					mOrderSummaryPromotion.setText(promotion);
				}
				else
				{
					mOrderSummaryPromotion.setVisibility(View.GONE);
				}
			}
			else
			{
				mOrderSummaryPromotion.setVisibility(View.GONE);
				mOrderSummarySavingsRow.setVisibility(View.GONE);
			}

			// Nb items
			mOrderSummaryItemsLayout.setVisibility(View.VISIBLE);
			mOrderSummaryItems.setText(getActivity().getString(R.string.order_summary_items, order.getDeliveryItemsQuantity()));
		}
	}

	@Override
	public void onStop()
	{
		super.onStop();
		B2BApplication.getContentServiceHelper().cancel(mOrderRequestId);
	}
}
