require 'json'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class FrendoGateway < Gateway
      TEST_URL = 'https://test10.frendo.com/FrendoAPI/api/v1/'
      LIVE_URL = 'https://www.frendo.com/FrendoAPI/api/v1/'

      self.supported_countries = ['US','CA']
      self.default_currency = 'CAD'
      self.supported_cardtypes = [:visa, :master]
      self.homepage_url = 'http://www.frendo.com/'
      self.display_name = 'Frendo'

      attr_reader :response_body

      def initialize(options = {})
        @options = options
        super
      end

      def purchase(amount, creditcard_or_account_number, options)
        if creditcard_or_account_number.is_a?(String)
          purchase_with_account_number(amount, creditcard_or_account_number, options)
        else
          purchase_with_credit_card(amount, creditcard_or_account_number, options)
        end
      end

      def store(creditcard, options = {})
        post = {}
        add_authentication(post)
        add_address(post, options)
        add_credit_card(post, creditcard)
        add_customer(post, options)

        commit('creditcard.add', post)
      end

      def unstore(options)
        post = {}
        add_authentication(post)
        add_customer(post, options)

        commit('creditcard.remove', post)
      end

      def update(creditcard, options)
        post = {}
        add_authentication(post)
        add_address(post, options)
        add_credit_card(post, creditcard)
        add_customer(post, options)

        commit('creditcard.update', post)
      end

      private

      def purchase_with_credit_card(money, creditcard, options = {})
        post = {}
        add_authentication(post)
        add_charity_type(post)
        add_address(post, options)
        add_invoice(post, money)
        add_customer(post, options)
        add_credit_card(post, creditcard)

        commit('order.create', post)
      end

      def purchase_with_account_number(money, account_number, options = {})
        post = {}
        add_authentication(post)
        add_charity_type(post)
        add_invoice(post, money)
        options[:customer][:account_number] = account_number
        add_customer(post, options)

        commit('order.createUend', post)
      end

      def add_charity_type(post)
        post['Charity'] = {}
        post['Charity']['Type'] = "Charity"
        post['Charity']['Id']   = "2"
      end

      def add_authentication(post)
        post['Authentication'] = {}
        post['Authentication']['Username'] = @options[:login]
        post['Authentication']['Password'] = @options[:password]
      end

      def add_address(post, options)
        if address = options[:billing_address] || options[:address]
          post['Address'] = {}
          post['Address']['Address']          = address[:address1].to_s
          post['Address']['City']             = address[:city].to_s
          post['Address']['Province']         = address[:state].to_s
          post['Address']['State']            = address[:state].to_s
          post['Address']['PostalCode']       = address[:zip].to_s
          post['Address']['Country']          = address[:country].to_s
          post['BillingAddress']              = post['Address']
        end
      end

      def add_credit_card(post, creditcard)
        post['CreditCard'] = {}
        post['CreditCard']['CardType']        = brand(creditcard)
        post['CreditCard']['CardNumber']      = creditcard.number
        post['CreditCard']['CardholderName']  = "#{creditcard.first_name} #{creditcard.last_name}"
        post['CreditCard']['ExpiryMonth']     = creditcard.month.to_s
        post['CreditCard']['ExpiryYear']      = creditcard.year.to_s
        post['CreditCard']['Cvv']             = creditcard.verification_value if creditcard.verification_value?
      end

      def add_invoice(post, money)
        post['Order'] = {}
        post['Order']['Amount']               = '%.2f' % (money.to_i/100.0) # convert cents to dollar string
        post['Order']['OrderDate']            = Time.now.strftime('%Y/%m/%d')
        post['Order']['OrderType']            = 'CC'
      end

      def add_customer(post, options)
        post['UserInfo'] = {}
        post['UserInfo']['FirstName']         = options[:customer][:first_name]
        post['UserInfo']['LastName']          = options[:customer][:last_name]
        post['UserInfo']['PhoneNumber']       = options[:customer][:phone]
        post['UserInfo']['Email']             = options[:customer][:email]
        post['UserInfo']['HostAddress']       = options[:customer][:ip]
        post['UserInfo']['AccountNumber']     = options[:customer][:account_number]
      end

      def commit(action, parameters)
        @response_body = JSON.parse(ssl_post(test? ? TEST_URL+action : LIVE_URL+action, parameters.to_json))

        Response.new(success?(@response_body),
                     message_from(@response_body),
                     @response_body,
                     :test => test?,
                     :authorization => authorization_from(@response_body))
      end

      def authorization_from(response)
        return response['Data']['CustomerCode'] if response['Data'] && response['Data']['CustomerCode']
        return response['Data']['ConfirmationNumber'] if response['Data'] && response['Data']['ConfirmationNumber']
        nil
      end

      def message_from(response)
        return response['Errors'][0]['Message'] if success?(response)
        response['Errors'][0]['Message'].split('-').last.try(:strip).try(:chomp)
      end

      def success?(response)
        response['Ok'] == '1'
      end

      def brand(creditcard)
        case creditcard.number.to_s[0].chr
        when '4'
          'VI'
        when '5'
          'MC'
        else
          'VI'
        end
      end

    end
  end
end

