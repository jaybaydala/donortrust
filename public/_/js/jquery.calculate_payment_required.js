(function($){
$.fn.calculate_payment_required = function( options ) {
  var settings = {
    'total_field'  : '#total',
    'append_field_to' : 'ol'
  };
  // <li id="paymentrequiredfield" class="string"><label>Payment still required</label> $<%= text_field_tag :payment_required, number_with_precision(@order.total), :disabled => "disabled", :style => "color:#333;" %></li>
  return this.each(function() {
    if (options) { $.extend(settings, options); }
    var accounts = $('input', this);
    var total_field = $(settings['total_field']);
    var total = total_field.val()-0;
    var payment_required_field = $('<input id="payment_required" value="'+total.toFixed(2)+'" disabled="disabled" style="color:#333;">');
    $(settings['append_field_to'], this).append($('<li id="payment_required_container" class="string">').append($("<label>").html('Payment still required')).append(payment_required_field));

    var numberize = function(num) {
      if (typeof(num) == 'string') num = num.replace(/[^0-9\.]+/g, '')-0;
      if (isNaN(num)) num = 0;
      return num;
    }

    var add = function(num1, num2) {
      return numberize(num1) + numberize(num2);
    }

    accounts.keyup(function() {
      var sum = 0;
      accounts.each(function() {
        sum = add(sum, $(this).val());
      });
      $(payment_required_field).val((total - sum).toFixed(2))
    });
    $(accounts[0]).keyup();
  });
};
})(jQuery);
