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
package com.hybris.mobile.lib.b2b.data;

import java.util.List;

import android.os.Parcel;
import android.os.Parcelable;


public class Category implements Parcelable
{
	private String id;
	private String name;
	private Category parent;
	private List<Category> subcategories;

	public Category()
	{
	}

	public String getId()
	{
		return id;
	}

	public void setId(String id)
	{
		this.id = id;
	}

	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public List<Category> getSubcategories()
	{
		return subcategories;
	}

	public void setSubcategories(List<Category> subcategories)
	{
		this.subcategories = subcategories;
	}

	public Category getParent()
	{
		return parent;
	}

	/**
	 * Return true if the category has subcategories
	 * 
	 * @return
	 */
	public boolean hasSubCategories()
	{
		return subcategories == null || subcategories.isEmpty();
	}

	/**
	 * Set the parent for the current node and each subcategories
	 * 
	 * @param parent
	 */
	public void setParent(Category parent)
	{
		this.parent = parent;

		if (subcategories != null)
		{
			for (Category catalog : subcategories)
			{
				catalog.setParent(this);
			}
		}
	}

	public static final Parcelable.Creator<Category> CREATOR = new Parcelable.Creator<Category>()
	{
		@Override
		public Category createFromParcel(Parcel source)
		{
			return new Category(source);
		}

		@Override
		public Category[] newArray(int size)
		{
			return new Category[size];
		}
	};

	public Category(Parcel in)
	{
		id = in.readString();
		name = in.readString();
		parent = in.readParcelable(this.getClass().getClassLoader());
	}

	@Override
	public int describeContents()
	{
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags)
	{
		dest.writeString(id);
		dest.writeString(name);
		dest.writeParcelable(parent, flags);
	}

	@Override
	public int hashCode()
	{
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + ((parent == null) ? 0 : parent.hashCode());
		result = prime * result + ((subcategories == null) ? 0 : subcategories.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj)
	{
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Category other = (Category) obj;
		if (id == null)
		{
			if (other.id != null)
				return false;
		}
		else if (!id.equals(other.id))
			return false;
		if (name == null)
		{
			if (other.name != null)
				return false;
		}
		else if (!name.equals(other.name))
			return false;
		if (parent == null)
		{
			if (other.parent != null)
				return false;
		}
		else if (!parent.equals(other.parent))
			return false;
		if (subcategories == null)
		{
			if (other.subcategories != null)
				return false;
		}
		else if (!subcategories.equals(other.subcategories))
			return false;
		return true;
	}

}
