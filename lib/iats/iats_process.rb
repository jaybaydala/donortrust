module IatsProcess
	protected
	def iats_payment( record )
	  # When taking CDN$, can we only have cardholder_name or will it work with the US$ info?
	  # if it would work, just use it all the time...
	  #iats.cardholder_name = "#{current_user.first_name} #{current_user.last_name}"
	  # When taking US$, you must remove cardholder_name and add the following before calling process_credit_card:
	  attributes = { 
	    :card_number => record[:credit_card], 
	    :card_expiry => "#{record.expiry_month.to_s.rjust(2,'0')}/#{record.expiry_year.to_s[-2,2]}", 
	    :dollar_amount => record[:amount].to_s, 
	    :first_name => record[:first_name], 
	    :last_name => record[:last_name], 
	    :street_address => record[:address], 
	    :city => record[:city], 
	    :state => record[:province], 
	    :zip_code => record[:postal_code]
	  }
	  require 'iats/iats_link'
	  iats = IatsLink.new(attributes)
	  iats.test_mode = ENV["RAILS_ENV"] == 'production' ? false : true
	  iats.agent_code = '2CFK99'
	  iats.password = 'K56487'
  
	  if iats.test_mode == false
	    iats.process_credit_card
	  else
	    iats.status = 1
	    iats.authorization_result = "OK:123456:N"
	  end
	  iats
	end
end
