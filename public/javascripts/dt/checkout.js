Event.observe(window, 'load', function() {
	if (form = $('paymentform')) {
	    $('remainder_amount_item').show();
	    new AccountTotal.initialize(form)
	}
});
var AccountTotal = {
	form: null,
	total_field: 'cart_total', 
	balance_field: 'account_balance', 
	amount_field: 'order_account_balance_total', 
	remainder_field: 'remainder', 

	initialize: function(form, type) {
		AccountTotal.form = form
		if ($(AccountTotal.amount_field)) {
			Event.observe($(AccountTotal.amount_field), 'change', AccountTotal.update)
		}
		AccountTotal.update()
	},
	update: function() {
	    amount_field = $(AccountTotal.amount_field)
	    total_field = $(AccountTotal.total_field)
	    balance_field = $(AccountTotal.balance_field)
	    remainder_field = $(AccountTotal.remainder_field)
		if (amount_field && total_field && balance_field && remainder_field) {
			amount = AccountTotal.filter_amount(amount_field.value)
			balance = AccountTotal.filter_amount(balance_field.value)
			if (amount > balance) {
			    amount = balance
			    amount_field.value = "$" + amount.toFixed(2)
			}
			total = AccountTotal.filter_amount(total_field.value)
			subtotal = total - amount
			if (isNaN(subtotal)) {
			    subtotal = total
			}
			subtotal = subtotal.toFixed(2)
			remainder_field.value = "$"+subtotal
		}
	},
	filter_amount: function(amount) {
		amount = amount.replace(/^\$/, '')
		amount = amount.replace(/,/g, '')
		amount -= 0
		return amount
	},

}
