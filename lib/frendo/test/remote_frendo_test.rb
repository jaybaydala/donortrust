require 'test_helper'

class RemoteFrendoTest < Test::Unit::TestCase


  def setup
    Base.mode = :test
    @gateway = FrendoGateway.new(fixtures(:frendo))

    @amount = 100
    @credit_card = credit_card('4715320629000001')
    @expired_card = credit_card('4715320629000001', { :year => 2010 })

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
    assert response = @gateway.purchase(@amount, @expired_card, @options)
    assert_failure response
    assert_equal 'You submitted an expired credit card number with your request. Please verify this parameter and retry the request.', response.message
  end

  def test_successful_store
    assert response = @gateway.store(@credit_card, @options)
    assert_success response
    assert_equal 'No errors', response.message
    assert_not_nil @account_number = response.params["Data"]["CustomerCode"]
  end

  def test_successful_unstore
    test_successful_store
    @options[:customer][:account_number] = @account_number
    assert response = @gateway.unstore(@options)
    assert_success response
    assert_equal "No errors", response.message
  end

  def test_successful_update
    test_successful_store
    @options[:customer][:account_number] = @account_number
    assert response = @gateway.update(@credit_card, @options)
    assert_success response
    assert_equal "No errors", response.message
  end

  def test_successful_purchase_with_stored_card
    test_successful_store
    assert response = @gateway.purchase(@amount, @account_number, @options)
    assert_success response
    assert_equal "No errors", response.message
  end

end
