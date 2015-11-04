#
# Information about the provided sample configuration 
#

Please find ready to use pre-configured examples of the hybris Commerce Suite and the hybris Data Hub to be used with the SAP integration content.

You'll find 2 directories of configuration:
- suite_config: 			contains configuration files to be used with the hybris Commerce Suite
- datahub_config: 			contains configuration files to be used with the hybris Data Hub

1) suite-config:
- local.properties:			contains configuration to modify run-time specific behaviour of the SAP integration content in the hybris Commerce Suite
- localextensions_aom.xml:	contains configuration to use an asynchronous integration approach using hybris Data Hub
- localextensions_som.xml:	contains configuration to use an synchronous integration approach 

2) datahub_config:
- local.properties:			configures the hybris Data Hub extensions for the SAP integration


Additionally you find a logback configuration which re-routes the log to a dedicated file “data hub.log” in the hybris/log directory.
This file has to be placed in the class path, for example in your Data Hub extensions directory.

[y] hybris Platform
Copyright (c) 2000-2014 hybris AG. All rights reserved.
This software is the confidential and proprietary information of hybris ("Confidential Information"). You shall not disclose such Confidential Information and shall use it only in accordance with the terms of the license agreement you entered into with hybris.
