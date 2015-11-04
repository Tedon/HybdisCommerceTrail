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
package com.hybris.mobile.lib.ui.listener;

import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.ListView;

import com.hybris.mobile.lib.ui.R;


/**
 * Listener for infinite scroll view
 */
public abstract class InfiniteScrollListener implements OnScrollListener
{
	private int currentPage = 1;
	private int previousTotalItemCount = 0;
	private boolean loading = true;

	public abstract void loadNextItems(int page);

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState)
	{
	}

	@Override
	public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount)
	{

		boolean loadNextItems = true;

		// We don't load when there is just the footer view
		if (view instanceof ListView && ((ListView) view).getFooterViewsCount() == totalItemCount)
		{
			loadNextItems = false;
		}

		if (loadNextItems)
		{
			// We update the page once we finished loading the dataset 
			if (totalItemCount > previousTotalItemCount && loading)
			{
				loading = false;
				previousTotalItemCount = totalItemCount;
			}

			// Getting the next results
			if ((totalItemCount - visibleItemCount) <= (firstVisibleItem + view.getContext().getResources()
					.getInteger(R.integer.infinite_scroll_treshold))
					&& !loading)
			{
				loading = true;
				loadNextItems(currentPage++);
			}
		}

	}

	/**
	 * Reset the listener status
	 */
	public void reset()
	{
		loading = true;
		currentPage = 1;
		previousTotalItemCount = 0;
	}

}
