require 'test_helper'

class RemoteFrendoTest < Test::Unit::TestCase


  def setup
    Base.mode = :test
    @gateway = FrendoGateway.new(fixtures(:frendo))

    @amount = 100
    @credit_card = credit_card('4715320629000001')
    @declined_card = credit_card('4715320629000001', { :year => 2010 })

    @options = {
      :address => { :address1 => '123 Main St.', :city => 'Southwest Mabou', :state => 'Nova Scotia', :zip => 'B0E 2W0', :country => 'CN' },
      :customer => { :first_name => 'John', :last_name => 'Doe', :phone => '9025551212', :email => 'john.doe@example.com', :ip => '123.123.123.123' }
    }
  end

  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'No errors', response.message
  end

  def test_unsuccessful_purchase
    assert response = @gateway.purchase(@amount, @declined_card, @options)
    assert_failure response
    assert_equal 'You submitted an expired credit card number with your request. Please verify this parameter and retry the request.', response.message
  end

end
