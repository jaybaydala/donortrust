require 'test_helper'

class FrendoTest < Test::Unit::TestCase
  def setup
    @gateway = FrendoGateway.new(
                 :login => 'myUsername@frendo.com',
                 :password => 'password'
               )

    @credit_card = credit_card
    @amount = 100

    @options = {
      :address => { :address1 => '123 Main St.', :city => 'Southwest Mabou', :state => 'Nova Scotia', :zip => 'B0E 2W0', :country => 'CN' },
      :customer => { :first_name => 'John', :last_name => 'Doe', :phone => '9025551212', :email => 'john.doe@example.com', :ip => '123.123.123.123' }
    }
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_instance_of Response, response
    assert_success response

    assert_equal '12345678901', response.authorization
    assert response.test?
  end

  def test_unsuccessful_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert response.test?
  end

  private

  def successful_purchase_response
    "{\"Ok\":\"1\",\"Errors\":[{\"Message\":\"No errors\",\"Code\":\"0\"}],\"Data\":{\"ConfirmationNumber\":\"12345678901\"}}"
  end

  def failed_purchase_response
    "{\"Ok\":\"0\",\"Errors\":[{\"Message\":\"An internal error occurred. Please retry the transaction.\",\"Code\":\"1000\"}],\"Data\":null}"
  end

end
