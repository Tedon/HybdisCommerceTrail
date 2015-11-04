<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="theme" tagdir="/WEB-INF/tags/shared/theme" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="format" tagdir="/WEB-INF/tags/shared/format" %>
<%@ taglib prefix="product" tagdir="/WEB-INF/tags/desktop/product" %>
<%@ taglib prefix="component" tagdir="/WEB-INF/tags/shared/component" %>


	<jsp:useBean id="random" class="java.util.Random" scope="application" />
	<c:set var="cid" value="reco${random.nextInt(1000)}"/>

	<div class="scroller" id="${cid}" data-title="${title}" data-model="${recommendationModel}"
		 data-prodcode="${productCode}" data-itemtype="${itemType}" data-includecart="${includeCart}"/>
	</div>
	
	<script type="text/javascript">
	   function loadData() {
	 		var divs = document.getElementsByClassName("scroller");

		   for(var i = 0; i < divs.length; i++){
			      if(divs[i].id.search("reco")> -1){
			    		var title = $("#"+divs[i].id).attr("data-title");
					   var recommendationModel = $("#"+divs[i].id).attr("data-model");
					   var productCode =$("#"+divs[i].id).attr("data-prodcode");
					   var itemType = $("#"+divs[i].id).attr("data-itemtype");
					   var includeCart = $("#"+divs[i].id).attr("data-includecart");
			    	  retrieveRecommendations(divs[i].id,title, recommendationModel, productCode, itemType, includeCart);
			      }
			   }		   
	   }
	   window.onload = loadData;
	</script>
