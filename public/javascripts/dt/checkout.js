Event.observe(window, 'load', function() {
	if (form = $('orderform') && $('create_account') && $('create_account').checked) {
	  $('password_entry').show();
	}
	/*
	if (form = $('paymentform') && $('totalfield')) {
	  $('totalfield').show();
	  $('paymentrequiredfield').show();
	  account_total = new AccountTotal(form)
	  account_total.buckets.each(function(bucket) {
	    $(bucket).observe('change', account_total.update_payments.bindAsEventListener(account_total))
	  });
	}
	*/
	if (form = $('paymentform') && $('create_account') && $('create_account').checked) {
	  $('password_entry').show();
  }
});
var AccountTotal = Class.create();
AccountTotal.prototype = {
	form: null,
	priority_buckets: $w('order_gift_card_payment order_account_payment'),
	buckets: new Array(),
	/*
	account_balance_field: 'account_balance', 
	account_amount_field: 'order_account_balance_payment', 
	cc_amount_field: 'order_credit_card_payment', 
	*/
	minimum_credit_card_payment_field: 'minimum_credit_card_payment', 
	credit_card_payment_field: 'order_credit_card_payment',
	cart_total_field: 'cart_total', 
	total_field: 'total', 
	payment_required_field: 'payment_required', 
	initialize: function(form) {
	  this.form = form
	  this.buckets = $$("#payment input").inject([], function(array, el) {
	    if (el.name.startsWith("order["))
	      array.push(el.id)
	    return array
	  });
	},
	update_payments: function(event) {
	  var element = event.element();
    // ensure the minimum credit payment is met - change that first
    credit_card_difference = 0
    if ($F(this.credit_card_payment_field) < $F(this.minimum_credit_card_payment_field)) {
      credit_card_difference = $F(this.minimum_credit_card_payment_field) - $F(this.credit_card_payment_field)
      this.set_currency_value(this.credit_card_payment_field, $F(this.minimum_credit_card_payment_field))
    }
    // any change to the credit payment gets adjusted in the target value
    // ie. if we have to add $5 to credit_card, we need to take $5 away...
    this.set_currency_value(element, $F(element)-credit_card_difference)
    // check all the buckets to ensure that none are over-limit
    this.buckets.each(function(bucket){
      well = bucket.sub(/^order_/, "").sub(/_payment$/, "_balance")
      if ($(well) && $F(well) && $F(well) < $F(bucket)) {
        account_total.set_currency_value(bucket, $F(well))
      }
    });
    // if there's any balance left, we should show the payment required field
    current_total = this.buckets.inject(0, function(sum, bucket){
      sum += ($F(bucket)-0)
      return sum
    });
    this.set_currency_value(this.total_field, current_total)
    balance = $F(this.cart_total_field) - current_total
    if (balance) {
      // we'll show the payment required field
      this.set_currency_value(this.payment_required_field, $F(this.cart_total_field) - current_total)
      if (!$("paymentrequiredfield").visible()) {$("paymentrequiredfield").blindDown({ duration: 0.8 })}
    } else {
      if ($("paymentrequiredfield").visible()) {$("paymentrequiredfield").blindUp({ duration: 0.8 })}
    }
	},
	set_currency_value: function(field, value) {
	  $(field).setValue(number_helper.to_currency(number_helper.filter_amount(value), false))
	}

/*
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
    min_cc_payment = this.get_min_cc_payment()
    if (cc_amount > cart_total) {
      cc_amount = cart_total
    }
    if (cc_amount < min_cc_payment) {
      cc_amount = min_cc_payment
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
    min_cc_payment = this.get_min_cc_payment()
    if (account_amount > cart_total) {
      account_amount = cart_total
    }
    if (account_balance < account_amount) {
      account_amount = account_balance
    }
    if (cart_total - account_amount < min_cc_payment) {
      account_amount = cart_total - min_cc_payment
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
	  value = this.to_dollars(value)
    $(this.cc_amount_field).value = number_helper.to_currency(value, false)
	},
	set_account_amount: function(value) {
	  value = this.to_dollars(value)
    $(this.account_amount_field).value = number_helper.to_currency(value, false)
	},
	set_total: function(value) {
	  value = this.to_dollars(value)
    $(this.total_field).value = number_helper.to_currency(value)
	},
	set_payment_required: function(value) {
	  value = this.to_dollars(value)
    $(this.payment_required_field).value = number_helper.to_currency(value)
	},
	get_account_balance: function() {
	  value = number_helper.filter_amount($(this.account_balance_field).value)
	  return this.to_cents(value);
	},
	get_min_cc_payment: function() {
	  value = number_helper.filter_amount($(this.min_cc_payment_field).value)
	  return this.to_cents(value);
	},
	get_cart_total: function() {
	  value = number_helper.filter_amount($(this.cart_total_field).value)
	  return this.to_cents(value);
  },
	get_cc_amount: function() {
	  value = number_helper.filter_amount($(this.cc_amount_field).value)
	  return this.to_cents(value);
	},
	get_account_amount: function() {
	  value = number_helper.filter_amount($(this.account_amount_field).value)
	  return this.to_cents(value);
  },
	get_total: function() {
	  value = number_helper.filter_amount($(this.total_field).value)
	  return this.to_cents(value);
	},
	to_cents: function(dollars) {
	  return dollars * 100;
	},
	to_dollars: function(cents) {
	  return cents / 100;
	}
*/
}

number_helper = {
  filter_amount: function(amount) {
	  if (typeof(amount) == 'string') {
	    amount = amount.replace(/[^0-9\.]+/g, '')
	  }
		if (isNaN(amount)) {
	    amount = 0
		}
		amount -= 0
		return amount
	},
  to_currency: function(amount, include_currency) {
    if (include_currency == null) include_currency = true
    amount = amount.toFixed(2)
    return (include_currency ? "$" : "") + amount
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
    amount = number_helper.filter_amount($('fund_cf_amount').value)
    $('fund_cf_amount').value = amount
    if ($('fund_cf_dollars').checked) {
      // do nothing
    } else if ($('fund_cf_percent').checked) {
      total = number_helper.filter_amount($('cart_total').value)
      amount = total * (amount/100)
    } else {
      $('fund_cf_amount').value = ""
      $('fund_cf_amount_calculated').value = ""
      return
    }
    if (amount) {
      amount = number_helper.to_currency(amount)
      amount += " will be added to your cart"
      $('fund_cf_amount_calculated').value = amount
    } else {
      $('fund_cf_amount_calculated').value = ""
    }    
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
  }
}
