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
package com.hybris.mobile.app.b2b.activity;

import java.util.Arrays;

import org.apache.commons.lang3.StringUtils;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.helper.SessionHelper;
import com.hybris.mobile.app.b2b.utils.UIUtils;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.UserInformation;
import com.hybris.mobile.lib.b2b.query.QueryLogin;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.http.utils.RequestUtils;
import com.hybris.mobile.lib.ui.listener.SubmitListener;


/**
 * Content Login validation
 * 
 */
public class LoginActivity extends Activity implements ResponseReceiver<UserInformation>, TextWatcher, AnimationListener
{

	private String mLoginRequestId = RequestUtils.generateUniqueRequestId();

	private EditText mEmailEditText;
	private EditText mPasswordEditText;
	private Button mLoginButton;
	private ImageView mHybrisLoginImg;
	private Button mClearEmailButton;
	private Button mClearPasswordButton;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login);

		// Initialize Components
		mLoginButton = (Button) findViewById(R.id.login_button);
		mEmailEditText = (EditText) findViewById(R.id.email_edit_text);
		mPasswordEditText = (EditText) findViewById(R.id.password_edit_text);
		mHybrisLoginImg = (ImageView) findViewById(R.id.hybris_login_img);
		mClearEmailButton = (Button) findViewById(R.id.clear_email_button);
		mClearEmailButton.setVisibility(View.INVISIBLE);
		mClearPasswordButton = (Button) findViewById(R.id.clear_password_button);
		mClearPasswordButton.setVisibility(View.INVISIBLE);

		mEmailEditText.setText(SessionHelper.getLastLoggedEmail());


		mEmailEditText.addTextChangedListener(this);
		mPasswordEditText.addTextChangedListener(this);

		setAnimation();

		// Add ClickListeners to the buttons
		mLoginButton.setOnClickListener(loginButtonListener);
		mPasswordEditText.setOnEditorActionListener(new SubmitListener()
		{

			@Override
			public void onSubmitAction()
			{
				signIn();

			}
		});

	}


	/**
	 * Define animations for the page
	 */
	private void setAnimation()
	{
		if (getResources().getBoolean(R.bool.animationOnLoginPage))
		{
			Animation animHybrisLoginImg = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.bounce);
			animHybrisLoginImg.setAnimationListener(this);
			mHybrisLoginImg.setVisibility(View.VISIBLE);
			mHybrisLoginImg.startAnimation(animHybrisLoginImg);

			Animation animClearCrossButton = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.fade_in);
			animClearCrossButton.setAnimationListener(this);
			if (StringUtils.isNotBlank(mEmailEditText.getText()))
			{
				mClearEmailButton.setVisibility(View.VISIBLE);
				mClearEmailButton.startAnimation(animClearCrossButton);
			}

			if (StringUtils.isNotBlank(mPasswordEditText.getText()))
			{
				mClearPasswordButton.setVisibility(View.VISIBLE);
				mClearPasswordButton.startAnimation(animClearCrossButton);
			}

			Animation animEmailEditText = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.move_right);
			animHybrisLoginImg.setAnimationListener(this);
			mEmailEditText.setVisibility(View.VISIBLE);
			mEmailEditText.startAnimation(animEmailEditText);

			Animation animPasswordEditText = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.move_left);
			animPasswordEditText.setAnimationListener(this);
			mPasswordEditText.setVisibility(View.VISIBLE);
			mPasswordEditText.startAnimation(animPasswordEditText);

			Animation animLoginButton = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.move_up);
			animLoginButton.setAnimationListener(this);
			mLoginButton.setVisibility(View.VISIBLE);
			mLoginButton.startAnimation(animLoginButton);
		}
	}

	/**
	 * Define Action when login button is clicked
	 */
	public OnClickListener loginButtonListener = new OnClickListener()
	{

		@Override
		public void onClick(View view)
		{
			signIn();
		}

	};


	@Override
	public void onResponse(Response<UserInformation> response)
	{
		// Save the email for next login
		SessionHelper.saveLastLoggedEmail(mEmailEditText.getText().toString());

		// Save refresh token for the user
		SessionHelper.setUserLoggedIn();

		// Updating the cart on session
		SessionHelper.updateCart(LoginActivity.this, mLoginRequestId, false);

		startActivity(new Intent(LoginActivity.this, DashboardActivity.class));
	}


	@Override
	public void onError(Response<DataError> response)
	{
		UIUtils.showAlertMessage(this, getString(R.string.error_title), response.getData().getErrorMessage().getMessage());

		// Clearing the field
		mPasswordEditText.setText("");
	}

	@Override
	public void afterTextChanged(Editable s)
	{
		clearAllEditText();
	}

	@Override
	public void beforeTextChanged(CharSequence s, int start, int count, int after)
	{
	}

	@Override
	public void onTextChanged(CharSequence s, int start, int before, int count)
	{
		setClickableLoginButton();
	}

	/**
	 * Blank Text Field when call
	 * 
	 * @param editText
	 *           : Field to clear
	 * @param button
	 *           : Action button to clear
	 */
	private void clearEditText(final EditText editText, final Button button)
	{

		if (StringUtils.isNotBlank(editText.getText()))
		{
			button.setOnClickListener(new View.OnClickListener()
			{
				@Override
				public void onClick(View v)
				{
					editText.setText("");
				}
			});

		}

		button.setVisibility(View.INVISIBLE);
	}

	/**
	 * Enable Login Button when all fields are correct
	 */
	private void setClickableLoginButton()
	{

		boolean editable = StringUtils.isNotBlank(mEmailEditText.getText()) && StringUtils.isNotBlank(mPasswordEditText.getText());

		mLoginButton.setEnabled(editable);
		mLoginButton.setClickable(editable);
	}

	@Override
	public void onAnimationEnd(Animation animation)
	{
	}

	@Override
	public void onAnimationRepeat(Animation animation)
	{
	}

	@Override
	public void onAnimationStart(Animation animation)
	{
	}

	@Override
	protected void onResume()
	{
		super.onResume();

		// Clear the fields and disable login button
		clearAllEditText();
		setClickableLoginButton();

	}

	/**
	 * Clear the different EditText
	 * 
	 */
	private void clearAllEditText()
	{
		clearEditText(mEmailEditText, mClearEmailButton);
		clearEditText(mPasswordEditText, mClearPasswordButton);

		if (StringUtils.isNotBlank(mEmailEditText.getText()))
		{
			mClearEmailButton.setVisibility(View.VISIBLE);
		}
		else
		{
			mClearEmailButton.setVisibility(View.INVISIBLE);
		}

		if (StringUtils.isNotBlank(mPasswordEditText.getText()))
		{
			mClearPasswordButton.setVisibility(View.VISIBLE);
		}
		else
		{
			mClearPasswordButton.setVisibility(View.INVISIBLE);
		}

	}

	private void signIn()
	{
		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(mEmailEditText.getText().toString());
		queryLogin.setPassword(mPasswordEditText.getText().toString());

		B2BApplication.getContentServiceHelper().login(LoginActivity.this, mLoginRequestId, queryLogin, false,
				Arrays.asList((View) mLoginButton, mEmailEditText, mPasswordEditText), new OnRequestListener()
				{

					@Override
					public void beforeRequest()
					{
						findViewById(R.id.sign_in_loading_spinner).setVisibility(View.VISIBLE);
					}

					@Override
					public void afterRequest()
					{
						findViewById(R.id.sign_in_loading_spinner).setVisibility(View.GONE);
					}
				});
	}

	@Override
	protected void onStop()
	{
		super.onStop();
		B2BApplication.getContentServiceHelper().cancel(mLoginRequestId);
	}

}
