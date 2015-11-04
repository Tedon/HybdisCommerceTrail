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
import java.util.Iterator;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import android.app.Activity;
import android.app.Fragment;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.widget.DrawerLayout;
import android.support.v4.widget.DrawerLayout.DrawerListener;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.ViewFlipper;

import com.hybris.mobile.app.b2b.B2BApplication;
import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.app.b2b.adapter.CatalogAdapter;
import com.hybris.mobile.app.b2b.utils.UIUtils;
import com.hybris.mobile.lib.b2b.data.Category;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.http.listener.OnRequestListener;
import com.hybris.mobile.lib.http.response.Response;
import com.hybris.mobile.lib.http.utils.RequestUtils;
import com.hybris.mobile.lib.ui.view.Alert;


/**
 * Fragment for the catalog menu
 */
public class CatalogMenuFragment extends Fragment implements ResponseReceiver<List<Category>>
{
	private static final String TAG = CatalogMenuFragment.class.getCanonicalName();

	private String mCatalogRequestId = RequestUtils.generateUniqueRequestId();

	private static final String SAVED_INSTANCE_CATEGORY = "SAVED_INSTANCE_CATEGORY";
	private static final String SAVED_INSTANCE_OPEN_BY_DEFAULT = "SAVED_INSTANCE_OPEN_BY_DEFAULT";
	private OnCategorySelectedListener mActivity;
	private ViewFlipper mCatalogMenuViewFlipper;
	private DrawerLayout mCatalogMenuDrawerLayout;
	private boolean mOpenByDefault = true;
	private String mCurrentCategoryId;

	/**
	 * Interface for activity communication
	 */
	public interface OnCategorySelectedListener
	{
		/**
		 * Method for callback
		 * 
		 * @param category
		 */
		public void onCategorySelected(Category category);
	}

	@Override
	public void onAttach(Activity activity)
	{
		super.onAttach(activity);

		// Make sure that the activity implements the callback interface
		try
		{
			mActivity = (OnCategorySelectedListener) activity;
		}
		catch (ClassCastException e)
		{
			Log.e(TAG, e.getLocalizedMessage());
		}
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
	{
		return inflater.inflate(R.layout.fragment_catalog_menu, container, false);
	}


	@Override
	public void onActivityCreated(Bundle savedInstanceState)
	{
		super.onActivityCreated(savedInstanceState);

		// Restore the current category
		if (savedInstanceState != null)
		{
			if (savedInstanceState.containsKey(SAVED_INSTANCE_CATEGORY))
			{
				mCurrentCategoryId = savedInstanceState.getString(SAVED_INSTANCE_CATEGORY);
			}

			if (savedInstanceState.containsKey(SAVED_INSTANCE_OPEN_BY_DEFAULT))
			{
				mOpenByDefault = savedInstanceState.getBoolean(SAVED_INSTANCE_OPEN_BY_DEFAULT);
			}
		}

		mCatalogMenuViewFlipper = (ViewFlipper) getActivity().findViewById(R.id.catalog_menu_fragment);

		// The catalog menu does not add any overlay on the screen
		mCatalogMenuDrawerLayout = ((DrawerLayout) getActivity().findViewById(R.id.catalog_menu_drawer));
		mCatalogMenuDrawerLayout.setScrimColor(Color.TRANSPARENT);

		// Call the API to get the catalog list
		B2BApplication.getContentServiceHelper().getCatalog(this, mCatalogRequestId, false, null, new OnRequestListener()
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
	public void onResume()
	{
		super.onResume();

		// Closing the drawer before loading the content
		mCatalogMenuDrawerLayout.closeDrawer(mCatalogMenuDrawerLayout.getChildAt(1));
	}

	@Override
	public void onResponse(Response<List<Category>> response)
	{
		// Setting the parent for each category of the catalog
		for (Category category : response.getData())
		{
			category.setParent(null);
		}

		// Init the list view with the catalog
		initListViewCatalog((ListView) getView().findViewById(R.id.catalog_menu_list_category), response.getData());

		// We come from a previous state
		if (StringUtils.isNotBlank(mCurrentCategoryId))
		{

			// Finding the previous category in the list
			List<Integer> indexesCategories = new ArrayList<Integer>();
			findCategory(mCurrentCategoryId, response.getData(), indexesCategories);

			// Building the child views of each category
			List<Category> nextSubCategories = response.getData();
			for (Integer currentIndex : indexesCategories)
			{
				final Category currentCategory = nextSubCategories.get(currentIndex);
				nextSubCategories = currentCategory.getSubcategories();

				buildChildrenView(currentCategory, false, false);

				mCatalogMenuViewFlipper.setInAnimation(null);
				mCatalogMenuViewFlipper.setOutAnimation(null);
				mCatalogMenuViewFlipper.setDisplayedChild(mCatalogMenuViewFlipper.getChildCount() - 1);
			}
		}

		// Open the catalog menu
		if (mOpenByDefault)
		{
			mCatalogMenuDrawerLayout.openDrawer(mCatalogMenuDrawerLayout.getChildAt(1));
		}

	}

	@Override
	public void onError(Response<DataError> response)
	{
		Alert.showCritical(getActivity(), response.getData().getErrorMessage().getMessage());
	}

	/**
	 * Disable the open by default behavior
	 */
	public void disableDefaultOpening()
	{
		mOpenByDefault = false;
	}

	/**
	 * Init the catalog list view with a list of categories
	 * 
	 * @param listView
	 * @param catalogs
	 */
	private void initListViewCatalog(ListView listView, List<Category> categories)
	{
		if (categories != null)
		{
			// On click listener for the different categories
			listView.setOnItemClickListener(new CategoryClickListener(categories));

			// Updating the list view
			listView.setAdapter(new CatalogAdapter(getActivity(), categories));
		}
	}

	/**
	 * Listener to switch from one category to her subcategories
	 */
	private class CategoryClickListener implements OnItemClickListener
	{

		private List<Category> categories;

		public CategoryClickListener(List<Category> catalogs)
		{
			this.categories = catalogs;
		}

		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position, long id)
		{
			final Category currentCategory = categories.get(position);
			mCurrentCategoryId = currentCategory.getId();

			// We handle the case of subcategories switching
			if (currentCategory.getSubcategories() != null && !currentCategory.getSubcategories().isEmpty())
			{
				buildChildrenView(currentCategory, false, true);
			}
			else
			{
				// Close the catalog menu
				mCatalogMenuDrawerLayout.closeDrawer(mCatalogMenuDrawerLayout.getChildAt(1));

				// Updating the content view
				updateContentView(currentCategory, true);
			}

		}

	}

	/**
	 * Add a child view to the view flipper
	 * 
	 * @param parent
	 * @param showCatalogMenuLogo
	 */
	private void buildChildrenView(final Category parent, boolean showCatalogMenuLogo, boolean showNext)
	{
		// Layout for the view
		final View view = getActivity().getLayoutInflater().inflate(R.layout.include_catalog_menu_categories,
				mCatalogMenuViewFlipper, false);

		TextView textViewTopCategoryName = (TextView) view.findViewById(R.id.catalog_menu_top_category_name);
		RelativeLayout relativeLayoutTopCategory = (RelativeLayout) view.findViewById(R.id.catalog_menu_top_category);
		ListView listViewCategories = (ListView) view.findViewById(R.id.catalog_menu_list_category);

		// We set to visible the top category name
		relativeLayoutTopCategory.setVisibility(View.VISIBLE);

		// Setting the top category name
		textViewTopCategoryName.setText(parent.getName());
		textViewTopCategoryName.setVisibility(View.VISIBLE);
		textViewTopCategoryName.setOnClickListener(new OnClickListener()
		{

			@Override
			public void onClick(View v)
			{
				if (parent.getParent() != null)
				{
					mCurrentCategoryId = parent.getParent().getId();
				}
				else
				{
					mCurrentCategoryId = null;
				}

				// On click of the top category, we go back to the top view
				mCatalogMenuViewFlipper.setInAnimation(getActivity(), R.anim.translate_left_to_origin);
				mCatalogMenuViewFlipper.setOutAnimation(getActivity(), R.anim.translate_origin_to_right);
				mCatalogMenuViewFlipper.showPrevious();

				// And we remove the view we just came by
				mCatalogMenuViewFlipper.removeViewAt(mCatalogMenuViewFlipper.getChildCount() - 1);

				// We display the catalog logo if we are on the top view
				if (mCatalogMenuViewFlipper.getChildCount() == 1)
				{
					showCatalogMenuLogo(view, true);
				}

				// Updating the content view
				updateContentView(parent.getParent(), false);

			}
		});

		// Setting the list for the sub categories
		initListViewCatalog(listViewCategories, parent.getSubcategories());

		// Show the subcategories
		mCatalogMenuViewFlipper.addView(view);

		if (showNext)
		{
			mCatalogMenuViewFlipper.setInAnimation(getActivity(), R.anim.translate_right_to_origin);
			mCatalogMenuViewFlipper.setOutAnimation(getActivity(), R.anim.translate_origin_to_left);
			mCatalogMenuViewFlipper.showNext();

			// Updating the content view once the ViewFlipper has finished his animation
			updateContentView(parent, false);
		}

		// Hidding the catalog logo on subcategories
		showCatalogMenuLogo(view, showCatalogMenuLogo);

	}

	/**
	 * Show/Hide the catalog logo
	 * 
	 * @param view
	 * @param show
	 */
	private void showCatalogMenuLogo(View view, boolean show)
	{
		view.findViewById(R.id.catalog_menu_logo).setVisibility(show ? View.VISIBLE : View.GONE);
	}

	/**
	 * This method update the content view once the viewflipper (for subcategories) or the drawer (for a leaf) has
	 * finished his animation (prevent the lag if the results arrive from persistence during the animation)
	 * 
	 * @param idCategory
	 * @param isLeaf
	 */
	private void updateContentView(final Category category, boolean isLeaf)
	{
		// For a leaf we update the content view after once the drawer is closed
		if (isLeaf)

		{
			mCatalogMenuDrawerLayout.setDrawerListener(new DrawerListener()
			{

				@Override
				public void onDrawerStateChanged(int arg0)
				{
				}

				@Override
				public void onDrawerSlide(View arg0, float arg1)
				{
				}

				@Override
				public void onDrawerOpened(View arg0)
				{
				}

				@Override
				public void onDrawerClosed(View arg0)
				{
					// Updating the content view
					mActivity.onCategorySelected(category);

					// We remove the listener
					mCatalogMenuDrawerLayout.setDrawerListener(null);
				}
			});
		}
		// For subcategories we wait for the end of the ViewFlipper animation
		else
		{
			if (mCatalogMenuViewFlipper.getInAnimation() != null)
			{
				mCatalogMenuViewFlipper.getInAnimation().setAnimationListener(new Animation.AnimationListener()
				{
					@Override
					public void onAnimationEnd(Animation animation)
					{
						// We update the content
						mActivity.onCategorySelected(category);
					}

					@Override
					public void onAnimationStart(Animation animation)
					{
					}

					@Override
					public void onAnimationRepeat(Animation animation)
					{
					}
				});
			}
			else
			{
				// We update the content
				mActivity.onCategorySelected(category);
			}

		}

	}

	@Override
	public void onSaveInstanceState(Bundle outState)
	{
		outState.putString(SAVED_INSTANCE_CATEGORY, mCurrentCategoryId);
		mOpenByDefault = mCatalogMenuDrawerLayout.isDrawerOpen(mCatalogMenuDrawerLayout.getChildAt(1));
		outState.putBoolean(SAVED_INSTANCE_OPEN_BY_DEFAULT, mOpenByDefault);
		super.onSaveInstanceState(outState);
	}

	/**
	 * Find a category in the list and save in a tab the path to get there (int positions)
	 * 
	 * @param categoryIdToFind
	 * @param categories
	 * @param indexesCategories
	 * @return
	 */
	public Category findCategory(String categoryIdToFind, List<Category> categories, List<Integer> indexesCategories)
	{

		Category category = null;
		boolean categoryFound = false;

		if (categories != null && !categories.isEmpty())
		{
			Iterator<Category> iterator = categories.iterator();
			int i = 0;

			// We continue until we find the category
			while (!categoryFound && iterator.hasNext())
			{
				indexesCategories.add(i);
				Category currentCategory = iterator.next();

				// Category found
				if (currentCategory.getId().equals(categoryIdToFind))
				{
					categoryFound = true;
					category = currentCategory;
				}
				// We go through the sub-categories
				else if (currentCategory.getSubcategories() != null)
				{
					category = findCategory(categoryIdToFind, currentCategory.getSubcategories(), indexesCategories);

					if (category != null)
					{
						return category;
					}
					// Category not found, we remove the index from the path
					else
					{
						indexesCategories.remove(indexesCategories.size() - 1);
					}

				}
				// Else we remove the index from the path
				else
				{
					indexesCategories.remove(indexesCategories.size() - 1);
				}

				i++;

			}

		}

		return category;

	}

	@Override
	public void onStop()
	{
		super.onStop();
		B2BApplication.getContentServiceHelper().cancel(mCatalogRequestId);
	}

}
