Event.observe(window, 'load', function() {
	if (form = $('orderform') && $('create_account') && $('create_account').checked) {
	    $('password_entry').show();
	}
	if (form = $('paymentform') && $('totalfield')) {
	    $('totalfield').show();
	    $('paymentrequiredfield').show();
	    account_total = new AccountTotal(form)
		if ($(account_total.account_amount_field)) {
		    Event.observe(account_total.account_amount_field, 'change', account_total.update_from_account_amount.bindAsEventListener(account_total))
		}
		if ($(account_total.cc_amount_field)) {
		    Event.observe(account_total.cc_amount_field, 'change', account_total.update_from_cc.bindAsEventListener(account_total))
		}
	}
	if (form = $('paymentform') && $('create_account') && $('create_account').checked) {
	    $('password_entry').show();
    }
});
var AccountTotal = Class.create();
AccountTotal.prototype = {
	form: null,
	balance_field: 'account_balance', 
	cart_total_field: 'cart_total', 
	account_amount_field: 'order_account_balance_total', 
	cc_amount_field: 'order_credit_card_total', 
	payment_required_field: 'payment_required', 
	total_field: 'total', 

	initialize: function(form, type) {
		this.form = form
		this.update_totals()
	},
	update_totals: function() {
	    cart_total = this.get_cart_total()
	    total = this.get_account_amount() + this.get_cc_amount()
	    remaining = cart_total - total
	    this.set_cc_amount(this.get_cc_amount())
	    this.set_account_amount(this.get_account_amount())
	    this.set_total(total)
	    this.set_payment_required(remaining)
	    if (remaining == 0) {
	        if ($("paymentrequiredfield").visible()) {$("paymentrequiredfield").blindUp({ duration: 0.8 })}
	    } else {
	        if (!$("paymentrequiredfield").visible()) {$("paymentrequiredfield").blindDown({ duration: 0.8 })}
	    }
	    if (this.get_account_amount() == cart_total) {
		    $('credit_card_details').hide();
		} else {
		    $('credit_card_details').show();
		}
	},
	update_from_cc: function() {
	    cart_total = this.get_cart_total()
	    account_balance = this.get_account_balance()
	    cc_amount = this.get_cc_amount()
	    if (cc_amount > cart_total) {
	        cc_amount = cart_total
	    }
	    account_amount = cart_total - cc_amount
	    if (account_balance < account_amount) {
	        account_amount = account_balance
	    }
	    this.set_cc_amount(cc_amount)
	    this.set_account_amount(account_amount)
	    this.update_totals()
	},
	update_from_account_amount: function() {
	    cart_total = this.get_cart_total()
	    account_balance = this.get_account_balance()
	    account_amount = this.get_account_amount()
	    if (account_amount > cart_total) {
	        account_amount = cart_total
	    }
	    if (account_balance < account_amount) {
	        account_amount = account_balance
	    }
	    cc_amount = cart_total - account_amount
	    if (cc_amount > cart_total) {
	        cc_amount = cart_total
	    }
	    this.set_cc_amount(cc_amount)
	    this.set_account_amount(account_amount)
	    this.update_totals()
	},
	
	set_cc_amount: function(value) {
	    $(this.cc_amount_field).value = this.to_currency(value)
	},
	set_account_amount: function(value) {
	    $(this.account_amount_field).value = this.to_currency(value)
	},
	set_total: function(value) {
	    $(this.total_field).value = this.to_currency(value)
	},
	set_payment_required: function(value) {
	    $(this.payment_required_field).value = this.to_currency(value)
	},
	
	get_account_balance: function() {
	    return this.filter_amount($(this.balance_field).value)
	},
	get_cart_total: function() {
	    return this.filter_amount($(this.cart_total_field).value)
    },
	get_cc_amount: function() {
	    return this.filter_amount($(this.cc_amount_field).value)
	},
	get_account_amount: function() {
	    return this.filter_amount($(this.account_amount_field).value)
    },
	get_total: function() {
	    return this.filter_amount($(this.total_field).value)
	},
	/*
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
	*/
	filter_amount: function(amount) {
	    if (typeof(amount) == 'string') {
	        // amount = amount.replace(/$/, '')
	        amount = amount.replace(/[^0-9\.]+/g, '')
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

Event.observe(window, 'load', function() {
    if ($('supportform')) {
        supportCF.toggler();
        supportCF.calculate();
	    Event.observe("fund_cf_percent", 'change', supportCF.toggler)
	    Event.observe("fund_cf_dollars", 'change', supportCF.toggler)
	    Event.observe("fund_cf_no", 'change', supportCF.toggler)
	    Event.observe("fund_cf_amount", 'change', supportCF.calculate)
	    Event.observe("fund_cf_percent", 'change', supportCF.calculate)
	    Event.observe("fund_cf_dollars", 'change', supportCF.calculate)
    }
});
supportCF = {
    toggler: function() {
        if ($('fund_cf_no').checked) {
            supportCF.hidePercent();
            supportCF.hideDollars();
            supportCF.hideAmount();
        } else if ($('fund_cf_percent').checked) {
            supportCF.showAmount();
            supportCF.showPercent();
            supportCF.hideDollars();
        } else if ($('fund_cf_dollars').checked) {
            supportCF.showAmount();
            supportCF.showDollars();
            supportCF.hidePercent();
        }
    },
    calculate: function() {
        amount = supportCF.filter_amount($('fund_cf_amount').value)
        $('fund_cf_amount').value = amount
        if ($('fund_cf_dollars').checked) {
            
        } else if ($('fund_cf_percent').checked) {
            total = supportCF.filter_amount($('cart_total').value)
            amount = total * (amount/100)
        } else {
            $('fund_cf_amount_calculated').value = ""
            return
        }
        amount = supportCF.to_currency(amount)
        amount += " will be added to your cart"
        $('fund_cf_amount_calculated').value = amount
        
    },
    showPercent: function() {
        $("fund_cf_percent_symbol").show();
    },
    hidePercent: function() {
        $("fund_cf_percent_symbol").hide();
    },
    showDollars: function() {
        $("fund_cf_dollars_symbol").show();
    },
    hideDollars: function() {
        $("fund_cf_dollars_symbol").hide();
    },
    showAmount: function() {
        $("fund_cf_amount_field").show();
    },
    hideAmount: function() {
        $('fund_cf_amount_calculated').value = ""
        $("fund_cf_amount").value = "";
        $("fund_cf_amount_field").hide();
    },
	filter_amount: function(amount) {
	    if (typeof(amount) == 'string') {
	        // amount = amount.replace(/$/, '')
	        amount = amount.replace(/[^0-9\.]+/g, '')
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
