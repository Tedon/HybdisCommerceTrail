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
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.app.Fragment;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.IntentConstants;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.activity.OrderConfirmationActivity;
import com.hybris.mobile.app.b2b.helper.SessionHelper;
import com.hybris.mobile.app.b2b.utils.UIUtils;
import com.hybris.mobile.app.b2b.view.CartViewUtils;
import com.hybris.mobile.lib.b2b.data.Address;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.DeliveryMode;
import com.hybris.mobile.lib.b2b.data.cart.Cart;
import com.hybris.mobile.lib.b2b.data.costcenter.CostCenter;
import com.hybris.mobile.lib.b2b.data.order.Order;
import com.hybris.mobile.lib.b2b.query.QueryPlaceOrder;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.http.utils.RequestUtils;
import com.hybris.mobile.lib.ui.view.Alert;
import com.hybris.mobile.lib.ui.view.ToolTip;


/**
 * Container that handle the details information for a specific product
 * 
 */
public class CheckoutFragment extends Fragment
{
	private String mCheckoutRequestId = RequestUtils.generateUniqueRequestId();

	private static final String SAVED_INSTANCE_COST_CENTER = "SAVED_INSTANCE_COST_CENTER";
	private static final String SAVED_INSTANCE_DELIVERY_ADDRESS = "SAVED_INSTANCE_DELIVERY_ADDRESS";
	private static final String SAVED_INSTANCE_DELIVERY_METHOD = "SAVED_INSTANCE_DELIVERY_METHOD";

	private Spinner mPaymentTypeSpinner;
	private Spinner mCostCenterSpinner;
	private Spinner mDeliveryAddressSpinner;
	private Spinner mDeliveryMethodSpinner;
	private EditText mPaymentNumberEditText;
	private Button mPlaceOrderButton;
	private LinearLayout mTermsConditionsLayout;
	private TextView mTermsConditionsText;
	private CheckBox mTermsConditionsCheckbox;
	private ToolTip mToolTip;
	private ArrayAdapter<String> mPaymentTypeAdapter;
	private ArrayAdapter<String> mCostCenterAdapter;
	private ArrayAdapter<String> mDeliveryAddressAdapter;
	private ArrayAdapter<String> mDeliveryMethodAdapter;
	private LinearLayout mPlacingOrderErrorMsgLayout;
	private LinearLayout mTermsConditionsErroMsgLayout;
	private List<CostCenter> mCostCenters;
	private List<Address> mAddresses;
	private List<DeliveryMode> mDeliveryModes;

	private int indexSelectedCostCenter = 0;
	private int indexSelectedDeliveryAddress = 0;
	private int indexSelectedDeliveryMethod = 0;


	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
	{
		return inflater.inflate(R.layout.fragment_checkout, container, false);
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState)
	{
		super.onActivityCreated(savedInstanceState);

		mPaymentTypeSpinner = (Spinner) getView().findViewById(R.id.checkout_account_payment_spinner);
		mPaymentNumberEditText = (EditText) getView().findViewById(R.id.checkout_payment_number_edittext);

		mPlaceOrderButton = (Button) getView().findViewById(R.id.checkout_place_order_button);

		mTermsConditionsLayout = (LinearLayout) getView().findViewById(R.id.checkout_terms_conditions_layout);
		mTermsConditionsText = (TextView) getView().findViewById(R.id.checkout_terms_conditions_text);
		mTermsConditionsCheckbox = (CheckBox) getView().findViewById(R.id.checkout_terms_conditions_checkbox);

		mToolTip = new ToolTip(getActivity(), getString(R.string.checkout_payment_number_button_description,
				getString(R.string.name_storefront)));

		mPlacingOrderErrorMsgLayout = (LinearLayout) getView().findViewById(R.id.checkout_placing_order_error_msg_layout);
		mTermsConditionsErroMsgLayout = (LinearLayout) getView().findViewById(R.id.checkout_terms_conditions_error_msg_layout);

		// Set Adapter		
		mPaymentTypeAdapter = new ArrayAdapter<String>(getActivity(), android.R.layout.simple_spinner_dropdown_item,
				new ArrayList<String>());
		mPaymentTypeSpinner.setAdapter(mPaymentTypeAdapter);

		mCostCenterAdapter = new ArrayAdapter<String>(getActivity(), android.R.layout.simple_spinner_dropdown_item,
				new ArrayList<String>());

		mDeliveryAddressAdapter = new ArrayAdapter<String>(getActivity(), android.R.layout.simple_spinner_dropdown_item,
				new ArrayList<String>());

		mDeliveryMethodAdapter = new ArrayAdapter<String>(getActivity(), android.R.layout.simple_spinner_dropdown_item,
				new ArrayList<String>());


		// Tooltip
		getView().findViewById(R.id.tooltip_button).setOnClickListener(new OnClickListener()
		{
			public void onClick(View v)
			{
				mToolTip.show(v, true);
				UIUtils.hideKeyboard(getActivity());
			}
		});

		// When clicking on the view, hide keyboard and remove focus
		getView().setOnTouchListener(new OnTouchListener()
		{

			@Override
			public boolean onTouch(View v, MotionEvent event)
			{
				UIUtils.hideKeyboard(getActivity());
				mPaymentNumberEditText.clearFocus();
				v.performClick();
				return false;
			}
		});

		// Listeners
		mTermsConditionsText.setOnClickListener(mTermsConditionsTextListener);
		mToolTip.setOnClickListener(mTooltipListener);
		mPaymentTypeSpinner.setOnItemSelectedListener(paymentTypeSpinnerListener);
		mPlaceOrderButton.setOnClickListener(mPlaceOrderButtonListener);

		initCostCenterSpinner();
		initDeliveryAddressSpinner();
		initDeliveryMethodSpinner();

		// Disable all spinners except the payment type and cost center
		mDeliveryAddressSpinner.setClickable(false);
		mDeliveryMethodSpinner.setClickable(false);

		// Restore the current spinner selection
		if (savedInstanceState != null)
		{
			if (savedInstanceState.containsKey(SAVED_INSTANCE_COST_CENTER))
			{
				indexSelectedCostCenter = savedInstanceState.getInt(SAVED_INSTANCE_COST_CENTER, 0);
			}
			if (savedInstanceState.containsKey(SAVED_INSTANCE_DELIVERY_ADDRESS))
			{
				indexSelectedDeliveryAddress = savedInstanceState.getInt(SAVED_INSTANCE_DELIVERY_ADDRESS, 0);
			}
			if (savedInstanceState.containsKey(SAVED_INSTANCE_DELIVERY_METHOD))
			{
				indexSelectedDeliveryMethod = savedInstanceState.getInt(SAVED_INSTANCE_DELIVERY_METHOD, 0);
			}
		}
	}

	@Override
	public void onSaveInstanceState(Bundle outState)
	{
		outState.putInt(SAVED_INSTANCE_COST_CENTER, mCostCenterSpinner.getSelectedItemPosition());
		outState.putInt(SAVED_INSTANCE_DELIVERY_ADDRESS, mDeliveryAddressSpinner.getSelectedItemPosition());
		outState.putInt(SAVED_INSTANCE_DELIVERY_METHOD, mDeliveryMethodSpinner.getSelectedItemPosition());

		super.onSaveInstanceState(outState);
	}

	/**
	 * Init the cost center spinner
	 */
	private void initCostCenterSpinner()
	{
		mCostCenterSpinner = (Spinner) getView().findViewById(R.id.checkout_cost_center_spinner);
		mCostCenterSpinner.setAdapter(mCostCenterAdapter);
		mCostCenterSpinner.setOnItemSelectedListener(costCenterSpinnerListener);
	}

	/**
	 * Init the delivery address spinner
	 */
	private void initDeliveryAddressSpinner()
	{
		mDeliveryAddressSpinner = (Spinner) getView().findViewById(R.id.checkout_delivery_address_spinner);
		mDeliveryAddressSpinner.setAdapter(mDeliveryAddressAdapter);
		mDeliveryAddressSpinner.setOnItemSelectedListener(deliveryAddressSpinnerListener);
	}

	/**
	 * Init the delivery method spinner
	 */
	private void initDeliveryMethodSpinner()
	{
		mDeliveryMethodSpinner = (Spinner) getView().findViewById(R.id.checkout_delivery_method_spinner);
		mDeliveryMethodSpinner.setAdapter(mDeliveryMethodAdapter);
		mDeliveryMethodSpinner.setOnItemSelectedListener(deliveryMethodSpinnerListener);
	}

	/**
	 * Populate the payment type adapter with a default value
	 */
	public void beginCheckOutFlow()
	{
		// We populate first the payment type
		mPaymentTypeAdapter.clear();
		mPaymentTypeAdapter.addAll(Arrays.asList(getResources().getString(R.string.payment_type_account_name)));
		mPaymentTypeAdapter.notifyDataSetChanged();
	}

	/**
	 * Populate the cost centers
	 */
	private void populateCostCenter()
	{
		if (mCostCenters != null && !mCostCenters.isEmpty())
		{

			// We re-init the spinner, because we always want to trigger the selection change even the index didnt change
			initCostCenterSpinner();

			// Create cost Center List Name
			List<String> costCenterList = new ArrayList<String>();
			for (CostCenter costCenter : mCostCenters)
			{
				costCenterList.add(costCenter.getName());
			}

			mCostCenterAdapter.clear();
			mCostCenterAdapter.addAll(costCenterList);
			mCostCenterAdapter.notifyDataSetChanged();

			mCostCenterSpinner.setSelection(indexSelectedCostCenter);
		}
	}

	/**
	 * Populate the delivery addresses
	 */
	private void populateDeliveryAddresses()
	{
		if (mAddresses != null && !mAddresses.isEmpty())
		{
			// We re-init the spinner, because we always want to trigger the selection change even the index didnt change (But the cost center changed)
			initDeliveryAddressSpinner();

			mDeliveryAddressSpinner.setClickable(true);

			// Create delivery address list
			List<String> deliveryAddressList = new ArrayList<String>();
			for (Address address : mAddresses)
			{
				deliveryAddressList.add(address.getFormattedAddress());
			}

			mDeliveryAddressAdapter.clear();
			mDeliveryAddressAdapter.addAll(deliveryAddressList);
			mDeliveryAddressAdapter.notifyDataSetChanged();

			mDeliveryAddressSpinner.setSelection(indexSelectedDeliveryAddress);
		}
	}

	/**
	 * Populate the delivery modes
	 */
	private void populateDeliveryModes()
	{
		if (mDeliveryModes != null && !mDeliveryModes.isEmpty())
		{
			// We re-init the spinner, because we always want to trigger the selection change even the index didnt change (But the delivery address changed)
			initDeliveryMethodSpinner();

			mDeliveryMethodSpinner.setClickable(true);

			// Create delivery address list
			ArrayList<String> deliveryModeList = new ArrayList<String>();
			for (DeliveryMode deliveryMode : mDeliveryModes)
			{
				if (StringUtils.isNotBlank(deliveryMode.getName()) && StringUtils.isNotBlank(deliveryMode.getDescription())
						&& deliveryMode.getDeliveryCost() != null
						&& StringUtils.isNotBlank(deliveryMode.getDeliveryCost().getFormattedValue()))
				{
					deliveryModeList.add(deliveryMode.getName() + " - " + deliveryMode.getDescription() + " - "
							+ deliveryMode.getDeliveryCost().getFormattedValue());
				}
			}

			mDeliveryMethodAdapter.clear();
			mDeliveryMethodAdapter.addAll(deliveryModeList);
			mDeliveryMethodAdapter.notifyDataSetChanged();

			mDeliveryMethodSpinner.setSelection(indexSelectedDeliveryMethod);
		}
	}

	/**
	 * Class to handle User interaction with account payment spinner
	 * 
	 */
	public OnItemSelectedListener paymentTypeSpinnerListener = new OnItemSelectedListener()
	{

		@Override
		public void onItemSelected(AdapterView<?> parent, View view, int position, long id)
		{
			// Setting the color to grey because this is the only choice
			((TextView) parent.getChildAt(0)).setTextColor(Color.GRAY);

			// Updating the payment type
			B2BApplication.getContentServiceHelper().updateCartPaymentType(new ResponseReceiver<Cart>()
			{

				@Override
				public void onResponse(Response<Cart> response)
				{
					// Getting the cost centers and updating the cost centers list
					B2BApplication.getContentServiceHelper().getCostCenters(new ResponseReceiver<List<CostCenter>>()
					{

						@Override
						public void onResponse(Response<List<CostCenter>> response)
						{
							mCostCenters = response.getData();
							populateCostCenter();
						}

						@Override
						public void onError(Response<DataError> response)
						{
							Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
						}
					}, mCheckoutRequestId, false, null, mOnRequestListener);
				}

				@Override
				public void onError(Response<DataError> response)
				{
					Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
				}
			}, mCheckoutRequestId, getResources().getString(R.string.payment_type_account_name), false, null, mOnRequestListener);
		}

		@Override
		public void onNothingSelected(AdapterView<?> parent)
		{
		}
	};

	/**
	 * Class to handle User interaction with cost center spinner
	 * 
	 */
	public OnItemSelectedListener costCenterSpinnerListener = new OnItemSelectedListener()
	{

		@Override
		public void onItemSelected(AdapterView<?> parent, View view, int position, long id)
		{
			// Updating the cost center for the cart
			B2BApplication.getContentServiceHelper().updateCartCostCenter(new ResponseReceiver<Cart>()
			{

				@Override
				public void onResponse(Response<Cart> response)
				{
					mAddresses = mCostCenters.get(mCostCenterSpinner.getSelectedItemPosition()).getUnit().getAddresses();
					populateDeliveryAddresses();
				}

				@Override
				public void onError(Response<DataError> response)
				{
					Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
				}
			}, mCheckoutRequestId, mCostCenters.get(position).getCode(), false, null, mOnRequestListener);

		}

		@Override
		public void onNothingSelected(AdapterView<?> parent)
		{
		}

	};

	/**
	 * Class to handle User interaction with delivery address spinner by sending request to update cart
	 */
	public OnItemSelectedListener deliveryAddressSpinnerListener = new OnItemSelectedListener()
	{

		@Override
		public void onItemSelected(AdapterView<?> parent, View view, int position, long id)
		{

			// Updating the delivery address for the cart
			B2BApplication.getContentServiceHelper().updateCartDeliveryAddress(new ResponseReceiver<Cart>()
			{

				@Override
				public void onResponse(Response<Cart> response)
				{
					B2BApplication.getContentServiceHelper().getDeliveryModes(new ResponseReceiver<List<DeliveryMode>>()
					{

						@Override
						public void onResponse(Response<List<DeliveryMode>> response)
						{
							mDeliveryModes = response.getData();
							populateDeliveryModes();
						}

						@Override
						public void onError(Response<DataError> response)
						{
							Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
						}
					}, mCheckoutRequestId, false, null, mOnRequestListener);
				}

				@Override
				public void onError(Response<DataError> response)
				{
					Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
				}
			}, mCheckoutRequestId, mAddresses.get(position).getId(), false, null, mOnRequestListener);

		}

		@Override
		public void onNothingSelected(AdapterView<?> parent)
		{
		}
	};

	/**
	 * Class to handle User interaction with delivery method spinner by sending request to update cart
	 */
	public OnItemSelectedListener deliveryMethodSpinnerListener = new OnItemSelectedListener()
	{
		@Override
		public void onItemSelected(AdapterView<?> parent, View view, int position, long id)
		{

			// Updating the delivery mode for the cart
			B2BApplication.getContentServiceHelper().updateCartDeliveryMode(new ResponseReceiver<Cart>()
			{

				@Override
				public void onResponse(Response<Cart> response)
				{
					SessionHelper.updateCart(getActivity(), mCheckoutRequestId, true);
				}

				@Override
				public void onError(Response<DataError> response)
				{
					Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
				}
			}, mCheckoutRequestId, mDeliveryModes.get(position).getCode(), false, null, mOnRequestListener);
		}

		@Override
		public void onNothingSelected(AdapterView<?> parent)
		{
		}
	};

	/**
	 * Tooltip message to inform user to set credit card on the storefront
	 */
	public OnClickListener mTooltipListener = new OnClickListener()
	{

		public void onClick(View v)
		{
			Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(getString(R.string.link_storefront)));
			getActivity().startActivity(intent);
		}
	};

	/**
	 * Define action when place order button is clicked to send REST call to create an order with current cart
	 * 
	 */
	public OnClickListener mPlaceOrderButtonListener = new OnClickListener()
	{

		@Override
		public void onClick(View v)
		{
			QueryPlaceOrder queryPlaceOrder = new QueryPlaceOrder();
			queryPlaceOrder.setTermsChecked(validateEntries());

			if (queryPlaceOrder.isTermsChecked())
			{
				mPlacingOrderErrorMsgLayout.setVisibility(View.GONE);
				B2BApplication.getContentServiceHelper().placeOrder(new ResponseReceiver<Order>()
				{
					@Override
					public void onResponse(Response<Order> response)
					{
						Intent intent = new Intent(getActivity(), OrderConfirmationActivity.class);
						intent.putExtra(IntentConstants.ORDER_CODE, response.getData().getCode());
						startActivity(intent);
					}

					@Override
					public void onError(Response<DataError> response)
					{
						Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
					}
				}, mCheckoutRequestId, queryPlaceOrder, false, Arrays.asList((View) mPlaceOrderButton), mOnRequestListener);

			}
			else
			{
				mPlacingOrderErrorMsgLayout.setVisibility(View.VISIBLE);
			}

		}
	};

	/**
	 * Validate data in the checkout form
	 * 
	 * @return
	 */
	private boolean validateEntries()
	{
		boolean valid = true;

		if (mCostCenterSpinner.getSelectedItem() == null || StringUtils.isBlank(mCostCenterSpinner.getSelectedItem().toString()))
		{
			mCostCenterSpinner.setEnabled(false);
			valid = false;
		}
		else
		{
			mCostCenterSpinner.setEnabled(true);
		}

		if (mDeliveryAddressSpinner.getSelectedItem() == null
				|| StringUtils.isBlank(mDeliveryAddressSpinner.getSelectedItem().toString()))
		{
			mDeliveryAddressSpinner.setEnabled(false);
			valid = false;
		}
		else
		{
			mDeliveryAddressSpinner.setEnabled(true);
		}

		if (mDeliveryMethodSpinner.getSelectedItem() == null
				|| StringUtils.isBlank(mDeliveryMethodSpinner.getSelectedItem().toString()))
		{
			mDeliveryMethodSpinner.setEnabled(false);
			valid = false;
		}
		else
		{
			mDeliveryMethodSpinner.setEnabled(true);
		}

		if (mTermsConditionsCheckbox.isChecked())
		{
			mTermsConditionsErroMsgLayout.setVisibility(View.GONE);
			mTermsConditionsLayout.setEnabled(true);
		}
		else
		{
			mTermsConditionsErroMsgLayout.setVisibility(View.VISIBLE);

			mTermsConditionsLayout.setEnabled(false);
			valid = false;
		}

		return valid;
	}


	/**
	 * Action when link in terms and conditions is clicked
	 * 
	 */
	public OnClickListener mTermsConditionsTextListener = new OnClickListener()
	{
		@Override
		public void onClick(View v)
		{
			Toast.makeText(getActivity(), "Terms and Conditions", Toast.LENGTH_SHORT).show();
		}
	};

	/**
	 * Populate the order summary
	 * 
	 * @param cart
	 */
	public void populateCartSummary(Cart cart)
	{
		//create views and populate them
		CartViewUtils.createCartSummary(getView(), cart, true);

		if (cart.getEntries() != null && !cart.getEntries().isEmpty())
		{
			mPlaceOrderButton.setEnabled(true);
		}
		else
		{
			mPlaceOrderButton.setEnabled(false);
		}
	}

	/**
	 * Show ProgressBar when Request is send and Hide ProgressBar when Response is received
	 * 
	 */
	private OnRequestListener mOnRequestListener = new OnRequestListener()
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
	};

	@Override
	public void onStop()
	{
		super.onStop();
		B2BApplication.getContentServiceHelper().cancel(mCheckoutRequestId);
	}
}
