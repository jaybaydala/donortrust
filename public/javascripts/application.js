// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function formLinkRedirector(form){
    var targetUrl = form.site.options[form.site.selectedIndex].value;
    window.location.href = targetUrl;
}


function ClearOptions(dropDownNameId) {
    var drp = document.getElementById(dropDownNameId);
    while (drp.options.length > 0) {
            drp.remove(0);
    }
}