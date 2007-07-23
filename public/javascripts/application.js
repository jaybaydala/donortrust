// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function formLinkRedirector(form){
    var targetUrl = form.site.options[form.site.selectedIndex].value;
    window.location.href = targetUrl;
}

Ajax.Responders.register({
	onCreate: function() {
		if($('ajax_busy') && Ajax.activeRequestCount > 0){
			Effect.Appear('ajax_busy', {durations: 0.5, queue: 'end'});
		}
	},
	onComplete: function(){
		if($('ajax_busy') && Ajax.activeRequestCount == 0){
			Effect.Fade('ajax_busy', {duration: 0.5, queue: 'end'});
		}
	}
});


function ClearOptions(dropDownNameId) {
    var drp = document.getElementById(dropDownNameId);
    while (drp.options.length > 0) {
            drp.remove(0);
    }
}
