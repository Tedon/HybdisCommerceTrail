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

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.hybris.mobile.app.b2b.R;
import com.hybris.mobile.lib.b2b.data.Category;


/**
 * Adapter for the items of the catalog menu
 */
public class CatalogAdapter extends ArrayAdapter<Category>
{
	private final List<Category> categories;

	public CatalogAdapter(Context context, List<Category> values)
	{
		super(context, R.layout.item_catalog_menu, values);
		this.categories = values;
	}

	@Override
	public int getCount()
	{
		return categories.size();
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent)
	{

		View rowView = null;

		if (convertView == null)
		{
			LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			rowView = inflater.inflate(R.layout.item_catalog_menu, parent, false);
		}
		else
		{
			rowView = convertView;
		}

		Category category = categories.get(position);

		// We set the category name
		((TextView) rowView.findViewById(R.id.catalog_menu_item_name)).setText(category.getName());

		// We hide the right arrow if there is no subcategories
		if (category.getSubcategories() == null || (category.getSubcategories() != null && category.getSubcategories().isEmpty()))
		{
			rowView.findViewById(R.id.catalog_menu_item_arrow_right).setVisibility(View.GONE);
		}

		return rowView;
	}
}
