require File.dirname(__FILE__) + '/credit_card'

class IatsLink
  attr_accessor :proxy_host, :proxy_port, :proxy_username, :proxy_password, 
    :agent_code, :password, :card_type, :card_number, :card_expiry, :dollar_amount, 
    :web_server, :preapproval_code, :invoice_number, :comment, :CVV2, :issue_number, 
    :test_mode, :first_name, :last_name, :street_address, :city, :state, :zip_code, 
    :cardholder_name, :status, :authorization_result
  attr_reader :version, :error

  # The IatsLink class is a port from the PHP/Java version provided by IATS.
  # Instantiate an IatsLink object, load up the values and run process_credit_card
  # @status, @authorization_result and, if required, @error are loaded during this process.
  # If @status == 1, it is a successful authorization. If not, @error contains a potentially useful error code as to what went wrong
  # 
  # While in testing, use:
  # iats.test_mode = true  # test_mode defaults to false
  # Never use test_mode = true on a production site since it returns values but doesn't actually process anything!
  # 
  # Here is some sample code for taking CDN$:
  # iats = IatsLink.new
  # iats.agent_code = 'NOTSURE'
  # iats.password = 'AGENTPASS'
  # iats.cardholder_name = 'Timothy A Glen'
  # iats.card_number = '4111111111111111'
  # iats.card_expiry = '08/09'
  # iats.dollar_amount = 100.00
  # iats.process_credit_card
  # if iats.status == 1
  #   iats.authorization_result
  # end
  # 
  # When taking US$, you must remove cardholder_name and add the following before calling process_credit_card:
  # iats.first_name = 'Timothy'
  # iats.last_name = 'Glen'
  # iats.street_address = '36 Hill Trail'
  # iats.city = 'Hollywood'
  # iats.state = 'CA'
  # iats.zip_code = '90210'

  def initialize(attributes = {})
    attributes.each {|k, v|
      if methods.include?("#{k}=")
        send("#{k}=".to_sym, v)
      end
    }
    @version ="1.30";

    # Initialize defaults.
    @web_server = "www.iats.ticketmaster.com"
    @test_mode = false

    # Initialize outputs.
    @status = 0
    @authorization_result = "REJECT: 1"
    @error = "AUTH ERROR!"
  end

  def proxy_server=(host, port)
    @proxy_host = host;
    @proxy_port = port;
  end

  def proxy_user=(user, password)
    @proxy_username = user
    @proxy_password = password
  end

  def process_credit_card
    # validate the card number
    begin
      if CreditCard.is_valid(@card_number) == false
        @status = 1
        @authorization_result = "REJECT: 40"
        @error = "INVALID CC NUMBER!"
        return
      end
    rescue Exception
      @status = 1
      @authorization_result = "REJECT: 40"
      @error = "INVALID CC NUMBER!"
      return
    end
    
    # grab the card type
    @card_type = CreditCard.cc_type(@card_number)
    if @card_type == 'UNKNOWN'
      @status = 1
      @authorization_result = "REJECT: 40"
      @error = "UNKNOWN CC TYPE!"
      return
    end
    
    # start the actual processing
    begin
      post_params = post_data
      RAILS_DEFAULT_LOGGER.debug "IATS post_data: #{post_params.inspect}"
      begin
        # set up the HTTP POST object
        require 'net/http'
        require 'net/https'
        req = Net::HTTP::Post.new(url.path, {'User-Agent' => user_agent})
        req.set_form_data(post_params)
        res = Net::HTTP.new(url.host, url.port, @proxy_host, @proxy_port, @proxy_username, @proxy_password)
        res.use_ssl = true if @test_mode == false
        #res.verify_mode = OpenSSL::SSL::VERIFY_NONE
        RAILS_DEFAULT_LOGGER.debug "Starting IATS processing" 
        resp = res.start {|http| http.request(req) }
        RAILS_DEFAULT_LOGGER.debug "IATS HTTP Result: #{resp.inspect}" 

        case resp
        when Net::HTTPSuccess, Net::HTTPRedirection
          #OK
          @status = 0
          @error = "AUTH ERROR!"
          @authorization_result = "REJECT: 1"
          
          # this is basically what they did in the ph pand java versions. I think it's a lot of work
          #iats_return = resp.body[resp.body.index(/AUTHORIZATION RESULT:/i), resp.body.length]
          #iats_return = iats_return[iats_return.index(":")+2, iats_return.index("<")-iats_return.index(":")-3]
          
          # use a quick Regexp instead. Doing it the other way gets rid of some 
          # requirements for php and java but Regexp is standard in Ruby
          iats_return = resp.body.match(/AUTHORIZATION RESULT:([^<]+)/)[1].strip
          RAILS_DEFAULT_LOGGER.debug "IATS HTML Result: #{iats_return.inspect}"
      
          if iats_return == ""
            @status = 0
            @error = "PAGE ERROR"
            @authorization_result = "REJECT: ERRPAGE"
          elsif iats_return.match(/OK:/)
            @status = 1
            @error = ""
            @authorization_result = iats_return
          else
            error_code = 'Timeout' if iats_return.match(/Timeout/)
            error_code = iats_return.match(/REJECT:([^$]+)/)[1].strip if !error_code
            @status = 1
            @error = IatsLink.error_message(error_code)
            @authorization_result = iats_return
          end
        else
          @status = 0
          @error = "Error: #{resp.code} #{resp.message}" 
          @authorization_result = "REJECT: ERRORPOST"
          return
        end
      rescue Exception
        @status = 0
        @error = "Error: ERRORCONN"
        @authorization_result = "REJECT: ERRORCONN"
        return
      end
    rescue Exception
      @status = 0
      @error = "12002"
      @authorization_result = "REJECT: SYSERROR"
      return
    end
  end

  def post_data
    post_data = { 'AgentCode' => @agent_code, 'Password' => @password, 'CCNum' => CreditCard.clean_num(@card_number),
      'CCExp' => @card_expiry, 'MOP' => @card_type||CreditCard.cc_type(@card_number), 'Total' => @dollar_amount }
    post_data['InvoiceNum'] = @invoice_number if @invoice_number && !@invoice_number.empty?
    post_data['PreapprovalCode'] = @preapproval_code if @preapproval_code && !@preapproval_code.empty?
    post_data['Comment'] = @comment if @comment && !@comment.empty?
    post_data['CVV2'] = @CVV2 if @CVV2 && !@CVV2.empty?
    post_data['IssueNum'] = @issue_number if @issue_number && !@issue_number.empty?
    if @cardholder_name && !@cardholder_name.empty?
      post_data['FirstName'] = @cardholder_name
    else
      post_data['FirstName'] = @first_name
      post_data['LastName'] = @last_name
      post_data['Address'] = @address
      post_data['City'] = @city
      post_data['state'] = @state
      post_data['ZipCode'] = @zip_code
    end
    post_data['Version'] = @version
    post_data
  end

  def self.error_message(err)
    error_map = {
      '1' => "Agent code has not been set up on the authorization system.", 
      '2' => "Unable to process transaction. Verify and re-enter credit card information.", 
      '3' => "Charge card expired.", 
      '4' => "Incorrect expiration date.", 
      '5' => "Invalid transaction. Verify and re-enter credit card information.", 
      '6' => "Transaction not supported by institution.", 
      '7' => "Lost or stolen card.", 
      '8' => "Invalid card status.", 
      '9' => "Restricted card status. Usually on corporate cards restricted to specific sales.", 
      '10' => "Error. Please verify and re-enter credit card information.", 
      '11' => "General decline code. Please call the number on the back of your credit card", 
      '14' => "The card is over the limit.", 
      '15' => "General decline code. Please call the number on the back of your credit card", 
      '16' => "Invalid charge card number. Verify and re-enter credit card information.", 
      '17' => "Unable to authorize transaction. Authorizer needs more information for approval.", 
      '18' => "Card not supported by institution.", 
      '19' => "Incorrect CVV2 security code (U.S.)", 
      '22' => "Bank timeout. Bank lines may be down or busy. Re-try transaction later.", 
      '23' => "System error. Re-try transaction later.", 
      '24' => "Charge card expired.", 
      '25' => "Capture card. Reported lost or stolen.", 
      '26' => "Invalid transaction, invalid expiry date. Please confirm and retry transaction.", 
      '27' => "Please have cardholder call the number of the back of credit card.", 
      '39' => "Contact Ticketmaster 1-888-955-5455.", 
      '40' => "Invalid cc number. Card not supported by Ticketmaster.", 
      '41' => "Invalid Expiry date.", 
      '100' => "DO NOT REPROCESS.", 
      'Timeout' => "The system has not responded in the time allotted. Please contact Ticketmaster at 1-888-955-5455."
    }
    message = error_map[err.to_s] if error_map.include?(err.to_s)
    message = error_map['1'] if !message
    message
  end
    
  protected
  def url
    require 'uri'
    post_action = "/trams/authresult.pro"
    address = ( @test_mode == true ? "http://" : "https://"  ) + @web_server + ':' + ( @test_mode == true ? '80' : '443' ) + post_action
    URI.parse(address)
  end

  def user_agent
    "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
  end
end
