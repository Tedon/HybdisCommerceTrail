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
package com.hybris.mobile.app.b2b.utils;

import net.hockeyapp.android.CrashManager;
import net.hockeyapp.android.FeedbackManager;
import net.hockeyapp.android.UpdateManager;
import android.app.Activity;
import android.content.Context;

import com.hybris.mobile.app.b2b.B2BApplication;


/**
 * Utility class for HockeyApp integration
 */
public class HockeyAppUtils
{

	/**
	 * HockeyApp crash manager
	 * 
	 * @param context
	 */
	public static void checkForCrashes(Context context)
	{
		CrashManager.register(context, B2BApplication.getConfiguration().getHockeyAppIdentifier());
	}

	/**
	 * HockeyApp for new updates on the app
	 * 
	 * @param context
	 */
	public static void checkForUpdates(Activity context)
	{
		UpdateManager.register(context, B2BApplication.getConfiguration().getHockeyAppIdentifier());
	}

	/**
	 * HockeyApp feedbacks
	 * 
	 * @param context
	 */
	public static void showFeedbackActivity(Context context)
	{
		FeedbackManager.register(context, B2BApplication.getConfiguration().getHockeyAppIdentifier());
		FeedbackManager.showFeedbackActivity(context);
	}

}
