/* 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Title :		charcount.js
Author : 		Terri Ann Swallow
URL : 		http://www.ninedays.org/
Project : 		Ninedays Blog
Copyright:		(c) 2008 Sam Stephenson
			This script is is freely distributable under the terms of an MIT-style license.

Description :	Functions in relation to limiting and displaying the number of characters allowed in a textarea
Version:		2.1
Changes:		Added overage override.  Read blog for updates: http://blog.ninedays.org/2008/01/17/limit-characters-in-a-textarea-with-prototype/

Created : 		1/17/2008 - January 17, 2008
Modified : 		5/20/2008 - May 20, 2008

Functions:
- charCounter(id, maxlimit, limited)	Function that counts the number of characters, alters the display number and the calss applied to the display number
- makeItCount(id, maxsize, limited)	Function called in the init() function, sets the listeners on the textarea(s) and instantiates the feedback display number if it does not exist
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

	function charCounter(id, maxlimit, limited){
		if (!$('counter-'+id)){
			$(id).insert({after: '<div id="counter-'+id+'"></div>'});
		}
		if($F(id).length >= maxlimit){
			if(limited){	$(id).value = $F(id).substring(0, maxlimit); }
			$('counter-'+id).addClassName('charcount-limit');
			$('counter-'+id).removeClassName('charcount-safe');
		} else {	
			$('counter-'+id).removeClassName('charcount-limit');
			$('counter-'+id).addClassName('charcount-safe');
		}
		$('counter-'+id).update( $F(id).length + '/' + maxlimit );	
			
	}
	
	function makeItCount(id, maxsize, limited){
		if(limited == null) limited = true;
		if ($(id)){
			Event.observe($(id), 'keyup', function(){charCounter(id, maxsize, limited);}, false);
			Event.observe($(id), 'keydown', function(){charCounter(id, maxsize, limited);}, false);
			charCounter(id,maxsize,limited);
		}
	}