Event.observe(window, 'load', function() {
	if (form = $('orderform') && $('create_account') && $('create_account').checked) {
	    $('password_entry').show();
	}
	if (form = $('paymentform') && $('totalfield')) {
	    $('totalfield').show();
	    new AccountTotal.initialize(form)
	}
	if (form = $('paymentform') && $('create_account') && $('create_account').checked) {
	    $('password_entry').show();
    }
	
});
var AccountTotal = {
	form: null,
	balance_field: 'account_balance', 
	cart_total_field: 'cart_total', 
	account_amount_field: 'order_account_balance_total', 
	cc_amount_field: 'order_credit_card_total', 
	total_field: 'total', 

	initialize: function(form, type) {
		AccountTotal.form = form
		if ($(AccountTotal.account_amount_field)) {Event.observe($(AccountTotal.account_amount_field), 'change', AccountTotal.update)}
		if ($(AccountTotal.cc_amount_field)) {Event.observe($(AccountTotal.cc_amount_field), 'change', AccountTotal.update)}
		AccountTotal.update()
	},
	update: function() {
	    account_amount_field = $(AccountTotal.account_amount_field)
	    cc_amount_field = $(AccountTotal.cc_amount_field)
	    cart_total_field = $(AccountTotal.cart_total_field)
	    balance_field = $(AccountTotal.balance_field)
	    total_field = $(AccountTotal.total_field)
		if (account_amount_field && cc_amount_field && cart_total_field && balance_field && total_field) {
		    // gather the values
		    account_amount = AccountTotal.filter_amount(account_amount_field.value)
			cc_amount = AccountTotal.filter_amount(cc_amount_field.value)
			balance = AccountTotal.filter_amount(balance_field.value)
			cart_total = AccountTotal.filter_amount(cart_total_field.value)
			// fix maximum account_amount to balance
			if (account_amount > balance) {
			    account_amount = balance
			}
			// add up the total
			total = AccountTotal.filter_amount(account_amount + cc_amount)
			// total payment can't be bigger than the cart_total
			if (total > cart_total) {
			    account_amount -= total - cart_total;
			    account_amount_field.value = AccountTotal.to_currency(account_amount);
			    AccountTotal.update();
			    return;
			}
			// if we're paying the whole amount from our account, there's no credit card necessary
			if (account_amount == cart_total) {
			    $('credit_card_details').hide();
			} else {
			    $('credit_card_details').show();
			}
			// update all the visible fields
		    account_amount_field.value = AccountTotal.to_currency(account_amount)
		    cc_amount_field.value = AccountTotal.to_currency(cc_amount)
			total_field.value = AccountTotal.to_currency(total)
        }
	},
	filter_amount: function(amount) {
	    if (typeof(amount) == 'string') {
    		amount = amount.replace(/^\$/, '')
    		amount = amount.replace(/,/g, '')
	    }
		if (isNaN(amount)) {
		    amount = 0
		}
		amount -= 0
		return amount
	},
    to_currency: function(amount) {
        return "$" + amount.toFixed(2)
    }
}
