module GiftTestHelper
  private
  def credit_card_params(options = {})
    { :credit_card => 4111111111111111, :card_expiry => '04/09', :first_name => 'Tim', :last_name => 'Glen', :address => '36 Example St.', :city => 'Guelph', :province => 'ON', :postal_code => 'N1E 7C5', :country => 'CA' }.merge(options)
  end

  def create_gift(options = {})
    options = credit_card_params if options.empty?
    Gift.create({ :amount => 1, :to_name => 'To Name', :to_email => 'to@example.com', :name => 'From Name', :email => 'from@example.com', :message => 'hello world!' }.merge(options))
  end
end

