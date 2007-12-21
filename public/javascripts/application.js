// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function onlyCurrency(e)
{
	var keyCode;
	if(!e.keyCode)
	{
		keyCode = e.which;
	}
	else
	{
		keyCode = e.keyCode;
	}
	
	//8 =  Backspace
	//39 = Right arrow
	//37 = Left arrow
	//13 = Enter
	//46 = Delete
	//190 = Decimal point (.)
	//9 = Tab
	
	if((keyCode == 189 || keyCode == 109) ||
		(keyCode >= 48 && keyCode <= 57) ||
		(keyCode >= 96 && keyCode <= 105) ||
			keyCode == 8 || keyCode == 39 || 
			keyCode == 37 || keyCode == 13 ||
			keyCode == 46 || keyCode == 190 ||
			keyCode == 9)
		{
			return true;
		}
	else
	{
		return false;
	}
}
function mark_agency_for_destroy(element){
   $(element).next('.should_destroy_agency').value = 1;
   $(element).up('.agency').hide();
}

function mark_source_for_destroy(element){
   $(element).next('.should_destroy_source').value = 1;
   $(element).up('.source').hide();
}

function textLinkRedirector(text){
    var targetUrl = text;
    window.location.href = targetUrl;
}

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

function submitRejection()
{
	var textArea = $('reason_reason');
	
	if(textArea && textArea.value != null && textArea.value != 'undefined'
		&& textArea.value != '')
		{
			document.forms['rejection_form'].submit();
		}
	else
	{
		alert('Please enter the rejection reason.');
	}
}
