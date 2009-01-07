// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function checkForm(fieldId, fieldDescription)
{
	var field = $(fieldId);
	if (field) {
		if (field.value && field.value != 'undefined' && field.value != '') {
			return true;
		}
	}
	alert("Please ensure that " + fieldDescription + " is filled in.")
	return false;
}

function onlyNumeric(e)
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

// Dynamic Version by: Nannette Thacker
// http://www.shiningstar.net
// Original by :  Ronnie T. Moore
// Web Site:  The JavaScript Source
// Use one function for multiple text areas on a page
// Limit the number of characters per textarea
function textCounter(field, cntfield, maxlimit) {
  if (field.value.length > maxlimit) 
    // if too long...trim it!
    field.value = field.value.substring(0, maxlimit);
  else
    // otherwise, update 'characters left' counter
    document.getElementById(cntfield).innerHTML = maxlimit - field.value.length;
    //cntfield.value = maxlimit - field.value.length;
}
