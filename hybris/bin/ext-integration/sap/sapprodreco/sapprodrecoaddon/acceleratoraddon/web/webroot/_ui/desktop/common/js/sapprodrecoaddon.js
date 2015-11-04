function addRecommendation(recoId) {
	return function(data){
		if (data !== ''){
			$("#" + recoId ).append(data);
			jQuery('#recommendationUL'+recoId).jcarousel({
				vertical: false
			});
		}	
		else {
			$("#" + recoId ).removeClass();
		}
	}
};

function retrieveRecommendations(id, title,recommendationModel,productCode,itemType,includeCart){	
	ajaxUrl = '/yacceleratorstorefront/action/recommendations/' + id + '/'+ title + '/'+ recommendationModel + '/' + productCode + '/' + itemType + '/' + includeCart;
	$.get(ajaxUrl, addRecommendation(id));
};