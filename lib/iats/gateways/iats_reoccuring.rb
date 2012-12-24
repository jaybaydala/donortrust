require 'rubygems'
require 'active_merchant'
require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class IatsReoccuringGateway < Gateway
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
      # UserID  = TEST88
      # Password  = TEST88
      # 
      # URL     = www.iats.ticketmaster.com
      # * Dollar Amount 1.00 OK: 678594;
      # * Dollar Amount 2.00 REJ: 15;
      # * Dollar Amount 3.00 OK: 678594;
      # * Dollar Amount 4.00 REJ: 15;
      # * Dollar Amount 5.00 REJ: 15;
      # * Dollar Amount 6.00 OK: 678594:X;
      # * Dollar Amount 7.00 OK: 678594:y;
      # * Dollar Amount 8.00 OK: 678594:A;
      # * Dollar Amount 9.00 OK: 678594:Z;
      # * Dollar Amount 10.00 OK: 678594:N;
      # * Dollar Amount 15.00, if CVV2=1234 OK: 678594:Y; if there is no CVV2: REJ: 19
      # * Dollar Amount 16.00 REJ: 2;
      # * Other Amount REJ: 15. 
      
      URL = 'https://www.iatspayments.com/'
      
      self.default_currency = "CAD"

      attr_reader :response_body

      # self.ssl_strict = false
      
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
      self.display_name = 'IATS, International Automated Transactions Service - Reoccuring Payments'
      
      def initialize(options = {})
        requires!(options, :login, :password)
        @currency = options[:currency] || IatsGateway.default_currency
        @options = options
        @version ="1.30"
        super
      end
      
      def create_customer(money, credit_card, options = {})
        post = {}
        add_amount(post, money, credit_card)
        add_invoice(post, options)
        add_credit_card(post, credit_card)
        add_subscription_data(post, options)
        add_customer_data(post, options)
        unless canadian_currency?
          add_address(post, options)
        end
        add_schedule_data(post, options)
        commit('create', post)
      end
      
      def update_customer(money, customer_code, credit_card, options = {})
        post = {}
        add_customer_code(post, customer_code)
        add_amount(post, money, credit_card)
        add_invoice(post, options)
        add_credit_card(post, credit_card) if credit_card
        add_subscription_data(post, options)
        add_customer_data(post, options)
        unless canadian_currency?
          add_address(post, options)
        end
        add_schedule_data(post, options)
        commit('update', post)
      end
      
      def delete_customer(customer_code, options = {})
        post = {}
        add_customer_code(post, customer_code)
        commit('delete', post)
      end
      
      def purchase_with_customer_code(money, customer_code, options = {})
        post = {}
        add_customer_code(post, customer_code)
        add_total(post, money)
        add_invoice(post, options)
        commit('process', post)
      end
      
      private
       
        def add_total(post, money)
          post[:Total] = amount(money)
        end
        
        def add_amount(post, money, credit_card="1")
          if test?
            credit_card_number = credit_card ? credit_card.number : credit_card
            credit_card_number = "success" unless %w(1 2 3 success failure error 4111111111111111).include?(credit_card_number)
            case credit_card_number.to_s
            when "4111111111111111"
              post[:Amount1] = amount(money) # manual tests
            when "2", "failure"
              post[:Amount1] = 16 # see iats-specific test notes above
            when "3", "error"
              post[:Amount1] = 2 # see iats-specific test notes above
            else
              post[:Amount1] = 1 # see iats-specific test notes above
            end
          else
            post[:Amount1] = amount(money)
          end
        end
          
        def add_customer_code(post, customer_code)
          post[:CustCode]  = customer_code
        end
          
        def add_customer_data(post, options)
        end
        
        def add_subscription_data(post, options)
          post[:reoccurringStatus] = options[:reoccurring_status] ? "ON" : "OFF" # ON, OFF 
          post[:beginDate]         = options[:begin_date].strftime("%Y-%m-%d") # YYYY-MM-DD 
          post[:endDate]           = options[:end_date] ? options[:end_date].strftime("%Y-%m-%d") : "" # YYYY-MM-DD
          post[:scheduleType]      = options[:schedule_type] # MONTHLY, WEEKLY
          post[:scheduleDate]      = options[:schedule_date] # (monthly:1-31; Weekly:1-7). 
        end
        
        def add_address(post, options)
          address = options[:billing_address] || options[:address]
          return if address.nil?
          post[:Address]        = address[:address]
          post[:City]           = address[:city]
          post[:State]          = address[:state]
          post[:ZipCode]        = address[:zip]
        end
        
        def add_invoice(post, options)
          post[:InvoiceNum] = options[:invoice_id]
          post[:Comment]    = options[:description]
        end
          
        def add_credit_card(post, credit_card)
          # if canadian_currency?
          #   post[:FirstName]  = credit_card.cardholder_name
          # else
          #   post[:FirstName]  = credit_card.first_name
          #   post[:LastName]   = credit_card.last_name
          # end
          post[:FirstName]  = credit_card.first_name
          post[:LastName]   = credit_card.last_name
          post[:MOP1]       = card_types[credit_card.type]
          # IATS requires 4111111111111111 for all test transactions
          post[:CCNum1]     = test? ? "4111111111111111" : credit_card.number
          post[:CCEXPIRY1]  = "#{format(credit_card.month, :two_digits)}/#{format(credit_card.year, :two_digits)}"
        end
          
        def add_schedule_data(post, options)
          post[:Reoccurring1] = options[:reoccuring_status] ? "ON" : "OFF"
          post[:BeginDate1] = options[:begin_date]
          post[:EndDate1] = options[:end_date]
          post[:ScheduleType1] = options[:schedule_type]
          post[:ScheduleDate1] = options[:schedule_date]
        end
          
        def commit(action, parameters)
          RAILS_DEFAULT_LOGGER.debug("Entering IatsReoccuringGateway::commit")
          RAILS_DEFAULT_LOGGER.debug("url: #{url(action).inspect}")
          RAILS_DEFAULT_LOGGER.debug("post_data: #{post_data(action, parameters).inspect}")
          headers = {}
          headers = { 'Authorization' => encoded_credentials } unless action == "process"
          RAILS_DEFAULT_LOGGER.debug("headers: #{headers.inspect}")
          @response_body = ssl_post(url(action), post_data(action, parameters), headers)
          response = parse(@response_body, action)
          RAILS_DEFAULT_LOGGER.debug("response: #{response.inspect}")
          Response.new(
            success?(response), 
            response[:message], 
            response,
            :test => test?,
            :authorization => response[:authorization],
            :fraud_review => response[:code] && %w(7 25).include?(response[:code]) ? true : false
          )
        end
        
        def parse(body, action)
          RAILS_DEFAULT_LOGGER.debug("Entering IatsReoccuringGateway::parse")
          RAILS_DEFAULT_LOGGER.debug(body.inspect)
          response = {:success => false}
          case action
          when "create"
            parse_create(body, response)
          when "update"
            parse_update(body, response)
          when "delete"
            parse_delete(body, response)
          when "process"
            parse_process(body, response)
          end
          response
        end
        
        def parse_create(body, response)
          if body.match(/HTTP 401./) || !body.match(/CCName|CCNum/)
            response[:code] = "1"
            response[:message] = response_code(response[:code])
            return response
          end
          if !body.match(/Reoccurring1/)
            response[:code] = "2"
            response[:message] = response_code(response[:code])
            return response
          end
          doc = Nokogiri::HTML(body)
          if input = doc.xpath('//input[@name="CustCode"]').first
            result = input[:value]
            unless result.blank?
              response[:success] = true
              response[:authorization] = result
              response[:customer_code] = result
            else
              response[:code] = matches[1].strip
              response[:message] = response_code(response[:code])
            end
          else
            response[:code] = "23"
            response[:message] = response_code(response[:code])
          end
          response
        end

        def parse_update(body, response)
          if body.match(/HTTP 401./) || !body.match(/CCName|CCNum/)
            response[:code] = "1"
            response[:message] = response_code(response[:code])
            return response
          end
          if !body.match(/Reoccurring1/)
            response[:code] = "2"
            response[:message] = response_code(response[:code])
            return response
          end
          response[:success] = true
          response[:authorization] = "OK: THE CUSTOMER HAS BEEN UPDATED"
        end

        def parse_delete(body, response)
          if body.match(/HTTP 401./) || !body.match(/CCName|CCNum/)
            response[:code] = "1"
            response[:message] = response_code(response[:code])
            return response
          end
          if !body.match(/Reoccurring1/)
            response[:code] = "2"
            response[:message] = response_code(response[:code])
            return response
          end
          response[:success] = true
          response[:authorization] = "OK: THE CUSTOMER HAS BEEN DELETED"
        end
        
        def parse_process(body, response)
          if matches = body.match(/AUTHORIZATION RESULT:([^<]+)/)
            result = matches[1].strip
            if matches = result.match(/OK:([^$]+)/)
              response[:success] = true
              response[:authorization] = matches[1].strip
            end
          else
            response[:code] = "2"
            response[:message] = response_code(response[:code])
          end
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
          @url = case action
            when "create"
              URL + "itravel/Customer_Create.pro"
            when "update"
              URL + "itravel/Customer_Update.pro"
            when "delete"
              URL + "itravel/Customer_Delete.pro"
            when "process"
              URL + "trams/custcodeauthresult.pro"
          end
          test? ? @url.sub(/^https/, "http") : @url
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
        
        def encoded_credentials
          login = test? ? "TEST88" : @options[:login]
          password  = test? ? "TEST88" : @options[:password]
          credentials = [login, password].join(':')
          RAILS_DEFAULT_LOGGER.debug("credentials: #{credentials.inspect}")
          "Basic " << Base64.encode64(credentials).strip
        end
        
    end
  end
end
