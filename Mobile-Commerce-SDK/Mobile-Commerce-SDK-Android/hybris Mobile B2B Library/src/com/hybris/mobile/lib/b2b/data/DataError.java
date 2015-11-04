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


public class DataError
{
	private List<ErrorMessage> errors;

	public List<ErrorMessage> getErrors()
	{
		return errors;
	}

	public void setErrors(List<ErrorMessage> errors)
	{
		this.errors = errors;
	}

	/**
	 * Get the first error on the list
	 * 
	 * @return
	 */
	public ErrorMessage getErrorMessage()
	{
		return (errors != null && !errors.isEmpty()) ? errors.get(0) : new ErrorMessage();
	}

	public static class ErrorMessage
	{
		private String message;
		private String reason;
		private String subject;
		private String subjectType;
		private String type;

		public String getMessage()
		{
			return message;
		}

		public void setMessage(String message)
		{
			this.message = message;
		}

		public String getReason()
		{
			return reason;
		}

		public void setReason(String reason)
		{
			this.reason = reason;
		}

		public String getSubject()
		{
			return subject;
		}

		public void setSubject(String subject)
		{
			this.subject = subject;
		}

		public String getSubjectType()
		{
			return subjectType;
		}

		public void setSubjectType(String subjectType)
		{
			this.subjectType = subjectType;
		}

		public String getType()
		{
			return type;
		}

		public void setType(String type)
		{
			this.type = type;
		}

	}

}
