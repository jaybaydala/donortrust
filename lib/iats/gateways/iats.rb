module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class IatsGateway < Gateway
      # You must use card number 4111111111111111 which only works for TEST88. 
      # You can get different reject codes by sending different dollar amounts. 
      # The amounts and the responses are listed below.
      #
      # You can also go to the IATS website, signin using the TEST88 account
      # and see your transactions in the journal.
      # 
      # Rather than a specific test url, IATS has user, 
      # password, url and value combos to elicit specific responses:
      # 
      # UserID 	= TEST88
      # Password 	= TEST88
      # 
      # URL 		= www.iats.ticketmaster.com
      # *	Dollar Amount 1.00 OK: 678594;
      # *	Dollar Amount 2.00 REJ: 15;
      # *	Dollar Amount 3.00 OK: 678594;
      # *	Dollar Amount 4.00 REJ: 15;
      # *	Dollar Amount 5.00 REJ: 15;
      # *	Dollar Amount 6.00 OK: 678594:;
      # *	Dollar Amount 7.00 OK: 678594:;
      # *	Dollar Amount 8.00 OK: 678594:;
      # *	Dollar Amount 9.00 OK: 678594:;
      # *	Dollar Amount 10.00 OK: 678594:;
      # *	Dollar Amount 15.00, if CVV2=1234 OK: 678594:; if there is no CVV2: REJ: 19
      # *	Dollar Amount 16.00 REJ: 2;
      # *	Other Amount REJ: 15. 
      
      URL = 'https://www.iatspayments.com/'
      
      self.default_currency = "CAD"

      attr_reader :response_body
      
      def canadian_currency?
        @currency == "CAD"
      end

      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['CA', 'US']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.iatspayments.com/'
      
      # The name of the gateway
      self.display_name = 'IATS, International Automated Transactions Service'
      
      def initialize(options = {})
        requires!(options, :login, :password)
        @currency = options[:currency] || IatsGateway.default_currency
        @options = options
        @version ="1.30"
        super
      end
      
      def purchase(money, credit_card, options = {})
        post = {}
        add_amount(post, money, credit_card)
        add_invoice(post, options)
        add_credit_card(post, credit_card)
        add_customer_data(post, options)
        unless canadian_currency?
          add_address(post, options)
        end

        commit('purchase', money, post)
      end

      private
      def add_amount(post, money, credit_card)
        if test?
          credit_card.number = "success" unless %w(1 2 3 success failure error 4111111111111111).include?(credit_card.number)
          case credit_card.number.to_s
            when "4111111111111111"
              post[:Total] = amount(money) # manual tests
            when "2", "failure"
              post[:Total] = 16 # see iats-specific test notes above
            when "3", "error"
              post[:Total] = 2 # see iats-specific test notes above
            else
              post[:Total] = 1 # see iats-specific test notes above
          end
        else
          post[:Total] = amount(money)
        end
      end
      
      def add_customer_data(post, options)
      end

      def add_address(post, options)
        address = options[:billing_address] || options[:address]
        return if address.nil?
        post[:StreetAddress]  = address[:address]
        post[:City]           = address[:city]
        post[:State]          = address[:state]
        post[:ZipCode]        = address[:zip]
      end

      def add_invoice(post, options)
        post[:InvoiceNum] = options[:invoice_id]
        post[:Comment]    = options[:description]
      end
      
      def add_credit_card(post, credit_card)
        if canadian_currency?
          post[:FirstName]  = credit_card.cardholder_name
        else
          post[:FirstName]  = credit_card.first_name
          post[:LastName]   = credit_card.last_name
        end
        post[:MOP]          = card_types[credit_card.type]
        # IATS requires 4111111111111111 for all test transactions
        post[:CCNum]        = test? ? "4111111111111111" : credit_card.number
        post[:CCExp]        = "#{format(credit_card.month, :two_digits)}/#{format(credit_card.year, :two_digits)}"
        post[:CVV2]         = credit_card.verification_value
      end
      
      def parse(body)
        response = {:success => false}
        if matches = body.match(/AUTHORIZATION RESULT:([^<]+)/)
          result = matches[1].strip
          if matches = result.match(/OK:([^$]+)/)
            response[:success] = true
            response[:authorization] = matches[1].strip
          elsif matches = result.match(/REJECT:([^$]+)/)
            response[:code] = matches[1].strip
            response[:message] = response_code(response[:code])
          else
            response[:code] = "23"
            response[:message] = response_code(response[:code])
          end
        else
          response[:code] = "23"
          response[:message] = response_code(response[:code])
        end
        response
      end     
      
      def commit(action, money, parameters)
        @response_body = ssl_post(url(action), post_data(action, parameters))
        response = parse(@response_body)
        Response.new(
          success?(response), 
          response[:message], 
          response,
          :test => test?,
          :authorization => response[:authorization],
          :fraud_review => response[:code] && %w(7 25).include?(response[:code]) ? true : false
          )
      end
      
      def success?(response)
        response[:success]
      end
      
      # Should run against the test servers or not?
      def test?
        @options[:test] || Base.gateway_mode == :test
      end
      
      def url(action)
        # return URL if test?
        case action
          when "purchase"
            URL + "trams/authresult.pro"
        end
      end
      
      def post_data(action, parameters = {})
        parameters[:AgentCode] = test? ? "TEST88" : @options[:login]
        parameters[:Password]  = test? ? "TEST88" : @options[:password]
        parameters[:Version] = @version
        parameters.reject{|k,v| v.blank?}.collect { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join("&")
      end
      
      CARD_TYPES = { 
        'visa'               => "VISA",
        'master'             => "MC",
        'american_express'   => "AMX",
        'discover'           => "DSC",
        'diners_club'        => "DC",
        'jcb'                => "DC"
      }

      def card_types
        CARD_TYPES
      end
      
      RESPONSE_CODES = {
        :r1 => "Agent code has not been set up on the authorization system.", 
        :r2 => "Unable to process transaction. Verify and re-enter credit card information.", 
        :r3 => "Charge card expired.", 
        :r4 => "Incorrect expiration date.", 
        :r5 => "Invalid transaction. Verify and re-enter credit card information.", 
        :r6 => "Transaction not supported by institution.", 
        :r7 => "Lost or stolen card.", 
        :r8 => "Invalid card status.", 
        :r9 => "Restricted card status. Usually on corporate cards restricted to specific sales.", 
        :r10  => "Error. Please verify and re-enter credit card information.", 
        :r11  => "General decline code. Please call the number on the back of your credit card", 
        :r14  => "The card is over the limit.", 
        :r15  => "General decline code. Please call the number on the back of your credit card", 
        :r16  => "Invalid charge card number. Verify and re-enter credit card information.", 
        :r17  => "Unable to authorize transaction. Authorizer needs more information for approval.", 
        :r18  => "Card not supported by institution.", 
        :r19  => "Incorrect CVV2 security code (U.S.)", 
        :r22  => "Bank timeout. Bank lines may be down or busy. Re-try transaction later.", 
        :r23  => "System error. Re-try transaction later.", 
        :r24  => "Charge card expired.", 
        :r25  => "Capture card. Reported lost or stolen.", 
        :r26  => "Invalid transaction, invalid expiry date. Please confirm and retry transaction.", 
        :r27  => "Please have cardholder call the number of the back of credit card.", 
        :r39  => "Contact Ticketmaster 1-888-955-5455.", 
        :r40  => "Invalid cc number. Card not supported by Ticketmaster.", 
        :r41  => "Invalid Expiry date.", 
        :r100 => "DO NOT REPROCESS.", 
        :rTimeout => "The system has not responded in the time allotted. Please contact Ticketmaster at 1-888-955-5455."
      }
      
      def response_codes
        RESPONSE_CODES
      end
      
      def response_code(code)
        if code.to_s.match(/^r/)
          return response_codes[code.to_sym]
        else
          return response_codes["r#{code}".to_sym]
        end
      end
    end
  end
end

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class CreditCard
      cattr_accessor :canadian_currency
      self.canadian_currency = false
      def self.canadian_currency?
        canadian_currency
      end
      
      # Essential attribute for canadian currency
      attr_accessor :cardholder_name
      def cardholder_name?
        !@cardholder_name.blank?
      end

      def validate_essential_attributes_with_canadian_currency
        if CreditCard.canadian_currency?
          errors.add :month,           "is not a valid month" unless valid_month?(@month)
          errors.add :year,            "expired"              if expired?
          errors.add :year,            "is not a valid year"  unless valid_expiry_year?(@year)
          errors.add :cardholder_name, "cannot be empty"      if @cardholder_name.blank?
        else
          validate_essential_attributes_without_canadian_currency
        end
        errors
      end
      alias_method_chain :validate_essential_attributes, :canadian_currency
      
      def name_with_canadian_currency
        if CreditCard.canadian_currency?
          "#{@cardholder_name}"
        else
          name_without_canadian_currency
        end
      end
      alias_method_chain :name, :canadian_currency
      
      def name_with_canadian_currency?
        if CreditCard.canadian_currency?
          cardholder_name?
        else
          name_without_canadian_currency?
        end
      end
      alias_method_chain :name?, :canadian_currency
    end
  end
end