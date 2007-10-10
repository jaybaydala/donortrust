Account = {
	toggle_personal_info: function(checked) {
		if (details = $$('.personalinfo')) {
			details.invoke( checked ? 'hide' : 'show' )
		}
		if (helps = $$('.underThirteen')) {
			helps.invoke( checked ? 'show' : 'hide' )
		}
	}
}
