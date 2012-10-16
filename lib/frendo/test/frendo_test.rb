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

  def test_credit_card_brand_abbreviations
    visa = credit_card('4242424242424242', :brand => 'visa')
    mastercard = credit_card('5413031000000000', :brand => 'master')
    assert_equal 'VI', @gateway.send(:brand, visa)
    assert_equal 'MC', @gateway.send(:brand, mastercard)
  end

  def test_successful_store
    @gateway.expects(:ssl_post).returns(successful_store_response)

    assert response = @gateway.store(@credit_card, @options)
    assert_success response
    assert_equal "No errors", response.message
    assert response.params["Data"]["CustomerCode"].present?
    assert_equal '12345678901', response.params["Data"]["CustomerCode"]
    @account_number = response.params["Data"]["CustomerCode"]
  end

  def test_successful_unstore
    @gateway.expects(:ssl_post).returns(successful_unstore_response)

    test_successful_store
    @options[:customer][:account_number] = @account_number
    assert response = @gateway.unstore(@options)
    assert_success response
    assert_equal "No errors", response.message
  end

  def test_update
    @gateway.expects(:ssl_post).returns(successful_update_response)

    test_successful_store
    @options[:customer][:account_number] = @account_number
    assert response = @gateway.update(@credit_card, @options)
    assert_success response
    assert_equal "No errors", response.message
    assert response.params["Data"]["CustomerCode"].present?
    assert_equal '12345678901', response.params["Data"]["CustomerCode"]
  end

  def test_successful_purchase_with_stored_card
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    test_successful_store
    assert response = @gateway.purchase(100, @account_number, @options)
    assert_success response
    assert_equal "No errors", response.message
    assert response.authorization.present?
  end

  private

  def successful_purchase_response
    "{\"Ok\":\"1\",\"Errors\":[{\"Message\":\"No errors\",\"Code\":\"0\"}],\"Data\":{\"ConfirmationNumber\":\"12345678901\"}}"
  end

  def failed_purchase_response
    "{\"Ok\":\"0\",\"Errors\":[{\"Message\":\"An internal error occurred. Please retry the transaction.\",\"Code\":\"1000\"}],\"Data\":null}"
  end

  def successful_store_response
    "{\"Ok\":\"1\",\"Errors\":[{\"Message\":\"No errors\",\"Code\":\"0\"}],\"Data\":{\"CustomerCode\":\"12345678901\"}}"
  end

  def successful_unstore_response
    "{\"Ok\":\"1\",\"Errors\":[{\"Message\":\"No errors\",\"Code\":\"0\"}],\"Data\":null}"
  end

  def successful_update_response
    "{\"Ok\":\"1\",\"Errors\":[{\"Message\":\"No errors\",\"Code\":\"0\"}],\"Data\":{\"CustomerCode\":\"12345678901\"}}"
  end

end
