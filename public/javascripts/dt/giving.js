Event.observe(window, 'load', function() {
	if (form = $('investmentform')) GivingTotal.initialize(form, 'investment')
	if (form = $('giftform')) GivingTotal.initialize(form, 'gift')
	if (form = $('depositform')) GivingTotal.initialize(form, 'deposit')
});
var GivingTotal = {
	form: null,
	amount_field: null,
	amount_total_field: 'amount_total',
	fund_cf_field: 'fund_cf',
	fund_cf_percentage_field: 'fund_cf_percentage',
	initialize: function(form, type) {
		GivingTotal.form = form
		GivingTotal.amount_field = type+"_amount"
		if ($(GivingTotal.amount_field)) {
			Event.observe($(GivingTotal.amount_field), 'change', GivingTotal.update)
		}
		if ($(GivingTotal.fund_cf_field)) {
			Event.observe($(GivingTotal.fund_cf_field), 'change', GivingTotal.update)
		}
		if ($(GivingTotal.fund_cf_percentage_field)) {
			Event.observe($(GivingTotal.fund_cf_percentage_field), 'change', GivingTotal.update)
		}
		GivingTotal.update()
	},
	update: function() {
		if (amount_field = $(GivingTotal.amount_field)) {
			total = GivingTotal.filter_amount(amount_field.value)
			if ($(GivingTotal.fund_cf_field) 
				&& $(GivingTotal.fund_cf_percentage_field) 
				&& $(GivingTotal.fund_cf_field).checked 
				&& $(GivingTotal.fund_cf_percentage_field).value) {
				percentage = GivingTotal.filter_percentage($(GivingTotal.fund_cf_percentage_field).value);
				if (percentage > 0) {
					total += (total*percentage)
				}
			}
			total = total.toFixed(2)
			if ($(GivingTotal.amount_total_field)) {
				$(GivingTotal.amount_total_field).value = "$"+total
			}
		}
	},
	filter_amount: function(amount) {
		amount = amount.replace(/^\$/, '')
		amount -= 0
		return amount
	},
	filter_percentage: function(percentage) {
		percentage = percentage.replace(/%$/, '')
		percentage -= 0
		return percentage/100
	}
}
