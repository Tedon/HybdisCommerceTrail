package de.hybris.platform.sap.core.jco.monitor.jaxb;

import javax.xml.parsers.DocumentBuilderFactory;

import de.hybris.platform.sap.core.common.DocumentBuilderFactoryUtil;


public class JcoDocumentBuilderFactory {
	
	private static volatile DocumentBuilderFactory instance = null;
	 
	private JcoDocumentBuilderFactory() { }
 
	public static DocumentBuilderFactory getInstance() {

		if (instance != null) {
			
			return instance;
			
		}else{
			
			synchronized(JcoDocumentBuilderFactory.class){
				
				if (instance != null) {
					
					return instance;
					
				}else{
					
					instance = DocumentBuilderFactory.newInstance();
					
					DocumentBuilderFactoryUtil.setSecurityFeatures(instance);
					
					return instance;
					
				}
			}
		}

	}
		 	
}


