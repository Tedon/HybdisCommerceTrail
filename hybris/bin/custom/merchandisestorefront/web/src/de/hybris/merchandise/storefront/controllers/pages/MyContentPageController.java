/**
 *
 */
package de.hybris.merchandise.storefront.controllers.pages;

import de.hybris.merchandise.storefront.controllers.ControllerConstants;
import de.hybris.platform.acceleratorstorefrontcommons.controllers.pages.AbstractPageController;
import de.hybris.platform.cms2.exceptions.CMSItemNotFoundException;

import org.apache.log4j.Logger;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;


/**
 * @author Artem_Kobeliev
 *
 */
@Controller
@Scope("tenant")
@RequestMapping(value = "/mycontentpage")
public class MyContentPageController extends AbstractPageController
{
	@SuppressWarnings("unused")
	private static final Logger LOG = Logger.getLogger(PasswordResetPageController.class);


	@RequestMapping(method = RequestMethod.GET)
	public String getPage(final Model model) throws CMSItemNotFoundException
	{
		storeCmsPageInModel(model, getContentPageForLabelOrId("myContentPage"));
		setUpMetaDataForContentPage(model, getContentPageForLabelOrId("myContentPage"));
		return ControllerConstants.Views.Pages.Trail.MyContentPage;
	}

}
