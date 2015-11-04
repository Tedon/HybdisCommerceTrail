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

import java.util.Calendar;

import org.apache.commons.lang3.StringUtils;


public class UserInformation
{
	private String userId;
	private String cartId;
	private String access_token;
	private String refresh_token;
	private long expires_in;
	private long issuedOn;
	private Calendar calendarTokenExpiration;
	private boolean tokenInvalid = false;

	public UserInformation()
	{
	}

	public UserInformation(String userId, String refreshToken)
	{
		this.userId = userId;
		this.refresh_token = refreshToken;
	}

	/**
	 * Return true if the token is expired
	 * 
	 * @return
	 */
	public boolean isTokenExpired()
	{
		if (calendarTokenExpiration == null)
		{
			calendarTokenExpiration = Calendar.getInstance();
			calendarTokenExpiration.setTimeInMillis(issuedOn + expires_in);
		}

		return calendarTokenExpiration.before(Calendar.getInstance());
	}

	public String getUserId()
	{
		return userId;
	}

	public void setUserId(String userId)
	{
		this.userId = userId;
	}

	public String getCartId()
	{
		return cartId;
	}

	public void setCartId(String cartId)
	{
		this.cartId = cartId;
	}

	public String getAccess_token()
	{
		return access_token;
	}

	public void setAccess_token(String access_token)
	{
		this.access_token = access_token;
	}

	public String getRefresh_token()
	{
		return refresh_token;
	}

	public void setRefresh_token(String refresh_token)
	{
		this.refresh_token = refresh_token;
	}

	public long getIssuedOn()
	{
		return issuedOn;
	}

	public void setIssuedOn(long issuedOn)
	{
		this.issuedOn = issuedOn;
	}

	public long getExpires_in()
	{
		return expires_in;
	}

	public void setExpires_in(long expires_in)
	{
		this.expires_in = expires_in;
	}

	public boolean isTokenInvalid()
	{
		return tokenInvalid || StringUtils.isBlank(access_token) || StringUtils.isBlank(refresh_token);
	}

	public void setTokenInvalid(boolean tokenInvalid)
	{
		this.tokenInvalid = tokenInvalid;
	}

}
