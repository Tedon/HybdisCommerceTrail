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
package com.hybris.mobile.lib.ui.view;

import org.apache.commons.lang3.StringUtils;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewPropertyAnimator;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.hybris.mobile.lib.ui.R;


/**
 * Alert panel
 */
public class Alert
{

	// Configuration
	private static final int HEIGHT = 100;
	private static final int DURATION = 3000;
	private static final int DURATION_OUT = 200;
	private static final int DURATION_IN = 200;
	private static Handler handler = new Handler();

	/**
	 * Enum for message type
	 */
	private enum Type
	{
		CRITICAL("CRITICAL"), ERROR("ERROR"), SUCCESS("SUCCESS"), WARNING("WARNING");

		private String type;

		Type(String type)
		{
			this.type = type;
		}

		public String getType()
		{
			return type;
		}

	}

	/**
	 * Show the alert success with optional configuration
	 * 
	 * @param context
	 * @param configuration
	 * @param text
	 */
	public static void showSuccess(Activity context, Configuration configuration, String text)
	{
		showAlert(context, Type.SUCCESS, configuration, text);
	}

	/**
	 * Show the alert warning with optional configuration
	 * 
	 * @param context
	 * @param configuration
	 * @param text
	 */
	public static void showWarning(Activity context, Configuration configuration, String text)
	{
		showAlert(context, Type.WARNING, configuration, text);
	}

	/**
	 * Show the alert error with optional configuration
	 * 
	 * @param context
	 * @param configuration
	 * @param text
	 */
	public static void showError(Activity context, Configuration configuration, String text)
	{
		showAlert(context, Type.ERROR, configuration, text);
	}

	/**
	 * Show the alert critical with optional configuration
	 * 
	 * @param context
	 * @param configuration
	 * @param text
	 */
	public static void showCritical(Activity context, Configuration configuration, String text)
	{
		showAlert(context, Type.CRITICAL, configuration, text);
	}

	/**
	 * Show the alert success
	 * 
	 * @param context
	 * @param text
	 */
	public static void showSuccess(Activity context, String text)
	{
		showAlert(context, Type.SUCCESS, null, text);
	}

	/**
	 * Show the alert warning
	 * 
	 * @param context
	 * @param text
	 */
	public static void showWarning(Activity context, String text)
	{
		showAlert(context, Type.WARNING, null, text);
	}

	/**
	 * Show the alert error
	 * 
	 * @param context
	 * @param text
	 */
	public static void showError(Activity context, String text)
	{
		showAlert(context, Type.ERROR, null, text);
	}

	/**
	 * Show the alert critical
	 * 
	 * @param context
	 * @param text
	 */
	public static void showCritical(Activity context, String text)
	{
		showAlert(context, Type.CRITICAL, null, text);
	}

	/**
	 * Show a custom alert by providing a configuration
	 * 
	 * @param context
	 * @param configuration
	 * @param text
	 */
	public static void show(Activity context, Configuration configuration, String text)
	{
		if (configuration == null)
		{
			throw new IllegalArgumentException("You must provide a configuration for the alert.");
		}
		else if (configuration.getColorBackgroundResId() == -1 || configuration.getColorTextResId() == -1)
		{
			throw new IllegalArgumentException("You must provide the text and background color for the configuration.");
		}

		showAlert(context, null, configuration, text);
	}

	/**
	 * Configure and call the method to show the alert
	 * 
	 * @param context
	 * @param messageType
	 * @param configuration
	 * @param text
	 */
	private static void showAlert(Activity context, Type messageType, Configuration configuration, final String text)
	{
		showAlertOnScreen(context, setUpConfiguration(context, configuration, messageType), text);
	}

	/**
	 * Configure the alert
	 * 
	 * @param context
	 * @param configuration
	 * @param messageType
	 * @return
	 */
	private static Configuration setUpConfiguration(Activity context, Configuration configuration, Type messageType)
	{

		if (configuration == null)
		{
			configuration = new Configuration();
		}

		// Main configuration
		if (configuration.getHeight() == -1)
		{
			configuration.setHeight(HEIGHT);
		}

		if (configuration.getDuration() == -1)
		{
			configuration.setDuration(DURATION);
		}

		if (configuration.getIconResId() == -1)
		{
			configuration.setIconResId(R.drawable.alert_close_icon_white);
		}

		if (configuration.getOrientation() == null)
		{
			configuration.setOrientation(Configuration.Orientation.TOP);
		}

		// Configuration specific to the message type
		if (messageType != null)
		{
			configuration.setMessageType(messageType.getType());

			switch (messageType)
			{
				case CRITICAL:
					configuration.setUpBackgroundColor(context.getResources().getColor(R.color.background_alert_critical));
					configuration.setUpTextColor(context.getResources().getColor(R.color.text_alert_critical));
					break;

				case ERROR:
					configuration.setUpBackgroundColor(context.getResources().getColor(R.color.background_alert_error));
					configuration.setUpTextColor(context.getResources().getColor(R.color.text_alert_error));
					break;

				case WARNING:
					configuration.setUpBackgroundColor(context.getResources().getColor(R.color.background_alert_warning));
					configuration.setUpTextColor(context.getResources().getColor(R.color.text_alert_warning));
					break;

				case SUCCESS:
					configuration.setUpBackgroundColor(context.getResources().getColor(R.color.background_alert_success));
					configuration.setUpTextColor(context.getResources().getColor(R.color.text_alert_success));
					break;
			}
		}

		return configuration;

	}


	/**
	 * Show the alert
	 * 
	 * @param context
	 * @param configuration
	 * @param text
	 */
	@SuppressLint("NewApi")
	private static void showAlertOnScreen(final Activity context, final Configuration configuration, final String text)
	{

		final ViewGroup mainView = ((ViewGroup) context.findViewById(android.R.id.content));
		boolean currentlyDisplayed = false;
		int viewId = R.id.alert_view_top;
		final TextView textView;

		if (configuration.getOrientation().equals(Configuration.Orientation.BOTTOM))
		{
			viewId = R.id.alert_view_bottom;
		}

		// Retrieving the view
		RelativeLayout relativeLayout = (RelativeLayout) mainView.findViewById(viewId);

		// Creating the view
		if (relativeLayout == null)
		{

			// Main layout
			relativeLayout = new RelativeLayout(context);
			relativeLayout.setId(viewId);
			relativeLayout.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, configuration.getHeight()));
			relativeLayout.setGravity(Gravity.CENTER);

			// Icon
			ImageView imageView = new ImageView(context);
			imageView.setImageResource(configuration.getIconResId());
			RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT,
					LayoutParams.WRAP_CONTENT);
			layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
			layoutParams.setMargins(0, 0, 25, 0);
			imageView.setLayoutParams(layoutParams);

			// Textview
			textView = new TextView(context);
			textView.setId(R.id.alert_view_text);
			textView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
			textView.setGravity(Gravity.CENTER);

			if (configuration.getOrientation().equals(Configuration.Orientation.TOP))
			{
				relativeLayout.setY(-configuration.getHeight());
			}
			else
			{
				relativeLayout.setY(mainView.getHeight());
			}

			// Adding the text view and imageview to the layout
			relativeLayout.addView(textView);
			relativeLayout.addView(imageView);

			// Adding the view to the global layout
			mainView.addView(relativeLayout, 0);
			relativeLayout.bringToFront();
			relativeLayout.requestLayout();
			relativeLayout.invalidate();
		}
		// View already exists
		else
		{
			textView = (TextView) relativeLayout.findViewById(R.id.alert_view_text);

			if (configuration.getOrientation().equals(Configuration.Orientation.TOP))
			{
				if (relativeLayout.getY() == 0)
				{
					currentlyDisplayed = true;
				}
			}
			else
			{
				if (relativeLayout.getY() < mainView.getHeight())
				{
					currentlyDisplayed = true;
				}
			}

			// The view is currently shown to the user
			if (currentlyDisplayed)
			{

				// If the message is not the same, we hide the current message and display the new one
				if (!StringUtils.equals(text, textView.getText()))
				{
					// Anim out the current message
					ViewPropertyAnimator viewPropertyAnimator = animOut(configuration, mainView, relativeLayout);

					final RelativeLayout relativeLayoutFinal = relativeLayout;

					// Anim in the new message after the animation out has finished
					if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN)
					{
						viewPropertyAnimator.setListener(new AnimatorListenerAdapter()
						{
							@Override
							public void onAnimationEnd(Animator animation)
							{
								animIn(context, configuration, relativeLayoutFinal, textView, mainView, text);
							}
						});
					}
					else
					{
						viewPropertyAnimator.withEndAction(new Runnable()
						{
							@Override
							public void run()
							{
								animIn(context, configuration, relativeLayoutFinal, textView, mainView, text);
							}
						});
					}

				}

			}

		}

		final RelativeLayout relativeLayoutFinal = relativeLayout;

		// Close the alert by clicking the layout
		relativeLayout.setOnTouchListener(new OnTouchListener()
		{

			@Override
			public boolean onTouch(View v, MotionEvent event)
			{
				animOut(configuration, mainView, relativeLayoutFinal);
				v.performClick();
				return true;
			}
		});

		if (!currentlyDisplayed)
		{
			// We anim in the alert
			animIn(context, configuration, relativeLayoutFinal, textView, mainView, text);
		}

	}

	/**
	 * Alert animation out
	 * 
	 * @param configuration
	 * @param viewToAnim
	 * @return
	 */
	private static ViewPropertyAnimator animOut(Configuration configuration, View mainView, View viewToAnim)
	{
		// Remove the anim out callback
		handler.removeCallbacksAndMessages(null);

		if (viewToAnim != null && configuration != null)
		{
			if (configuration.getOrientation().equals(Configuration.Orientation.TOP))
			{
				return viewToAnim.animate().translationY(-configuration.getHeight()).setDuration(DURATION_OUT);
			}
			else
			{
				return viewToAnim.animate().translationY(mainView.getHeight()).setDuration(DURATION_OUT);
			}
		}

		return null;
	}

	/**
	 * Alert animation in
	 * 
	 * @param context
	 * @param configuration
	 * @param viewToAnim
	 * @param textView
	 * @param mainView
	 * @param text
	 */
	private static void animIn(Context context, final Configuration configuration, final View viewToAnim, TextView textView,
			final View mainView, String text)
	{
		// Colors
		textView.setTextColor(configuration.getColorTextResId());
		viewToAnim.setBackgroundColor(configuration.getColorBackgroundResId());

		// Content Description
		viewToAnim.setContentDescription(configuration.getMessageType());

		// Setting the text
		textView.setText(text);

		// Animation In
		if (configuration.getOrientation().equals(Configuration.Orientation.TOP))
		{
			viewToAnim.animate().translationY(0).setDuration(DURATION_IN);
		}
		else
		{
			viewToAnim.animate().translationY(mainView.getHeight() - configuration.getHeight()).setDuration(DURATION_IN);
		}

		// Delayed animation out
		handler.postDelayed(new Runnable()
		{
			@Override
			public void run()
			{
				animOut(configuration, mainView, viewToAnim);
			}
		}, configuration.getDuration());

	}

	/**
	 * Class for configuring the Alert
	 */
	public static class Configuration
	{
		private int duration = -1;
		private int height = -1;
		private int colorBackgroundResId = -1;
		private int colorTextResId = -1;
		private int iconResId = -1;
		private Orientation orientation;
		private String messageType;

		public enum Orientation
		{
			TOP, BOTTOM;
		}

		public Orientation getOrientation()
		{
			return orientation;
		}

		public void setOrientation(Orientation orientation)
		{
			this.orientation = orientation;
		}

		public int getDuration()
		{
			return duration;
		}

		public void setDuration(int duration)
		{
			this.duration = duration;
		}

		public int getHeight()
		{
			return height;
		}

		public void setHeight(int height)
		{
			this.height = height;
		}

		public int getColorBackgroundResId()
		{
			return colorBackgroundResId;
		}

		public void setColorBackgroundResId(int colorBackgroundResId)
		{
			this.colorBackgroundResId = colorBackgroundResId;
		}

		public int getColorTextResId()
		{
			return colorTextResId;
		}

		public void setColorTextResId(int colorTextResId)
		{
			this.colorTextResId = colorTextResId;
		}

		public int getIconResId()
		{
			return iconResId;
		}

		public void setIconResId(int iconResId)
		{
			this.iconResId = iconResId;
		}

		public String getMessageType()
		{
			return messageType;
		}

		public void setMessageType(String messageType)
		{
			this.messageType = messageType;
		}

		private void setUpBackgroundColor(int resId)
		{
			if (this.getColorBackgroundResId() == -1)
			{
				this.setColorBackgroundResId(resId);
			}
		}

		private void setUpTextColor(int resId)
		{
			if (this.getColorTextResId() == -1)
			{
				this.setColorTextResId(resId);
			}
		}

	}

}
