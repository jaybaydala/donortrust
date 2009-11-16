require File.dirname(__FILE__) + '/../../../spec_helper'
require 'active_merchant'
require 'iats/gateways/iats_reoccuring'

describe ActiveMerchant::Billing::IatsReoccuringGateway do
  before do
    @options = {
      :address => {
        :address => "36 Foo Street",
        :city    => "Calgary",
        :state   => "AB",
        :zip     => "T2Y 3N2"
      },
      :reoccurring_status => false,
      :begin_date => Date.today,
      :end_date => Date.today + 10.years,
      :schedule_type => "MONTHLY" # MONTHLY, WEEKLY
    }
    @amount = 10 * 100 # so cents are represented as an integer - gateway expects it
    @credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number          => 1, # 1 to succeed, 2 or 3 to fail
      :month           => 1,
      :year            => Time.now.year+1,
      :first_name => "UEnd:",
      :last_name  => "Tester",
      :verification_value  => 989
    )

    @gateway = ActiveMerchant::Billing::IatsReoccuringGateway.new(:login => "TEST88", :password => "TEST88")
  end
  
  context "the create_customer method" do
    before do
      @gateway.stub(:ssl_post).and_return(File.read(File.join(fixture_path, "iats", "iats_create_response.html")))
    end
    it "should return a Response" do
      response = @gateway.create_customer(@amount, @credit_card, @options)
      response.class.should == ActiveMerchant::Billing::Response
    end
    it "should contain a customer_code" do
      response = @gateway.create_customer(@amount, @credit_card, @options)
      response.params["customer_code"].should_not be_blank
    end
  end
  context "the update_customer method" do
    before do
      @credit_card.last_name = "TesterUpdate"
      # @gateway.stub(:ssl_post).and_return(File.read(File.join(fixture_path, "iats", "iats_create_response.html")))
      response = @gateway.create_customer(@amount, @credit_card, @options)
      @options[:customer_code] = response.params["customer_code"]
      # @gateway.stub(:ssl_post).and_return(File.read(File.join(fixture_path, "iats", "iats_update_response.html")))
    end
    it "should return a Response" do
      response = @gateway.update_customer(@amount, @options[:customer_code], @credit_card, @options)
      response.class.should == ActiveMerchant::Billing::Response
    end
    it "should be successful" do
      response = @gateway.update_customer(@amount, @options[:customer_code], @credit_card, @options)
      response.success?.should == true
      response.authorization.should == "OK: THE CUSTOMER HAS BEEN UPDATED"
    end
  end

  context "the delete_customer method" do
    before do
      @gateway.stub(:ssl_post).and_return(File.read(File.join(fixture_path, "iats", "iats_create_response.html")))
      response = @gateway.create_customer(@amount, @credit_card, @options)
      @options[:customer_code] = response.params["customer_code"]
      @gateway.stub(:ssl_post).and_return(File.read(File.join(fixture_path, "iats", "iats_update_response.html")))
    end
    it "should return a Response" do
      response = @gateway.delete_customer(@options[:customer_code], @options)
      response.class.should == ActiveMerchant::Billing::Response
    end
    it "should be successful" do
      response = @gateway.delete_customer(@options[:customer_code], @options)
      response.success?.should == true
      response.authorization.should == "OK: THE CUSTOMER HAS BEEN DELETED"
    end
  end

  context "the purchase_with_customer_code method" do
    before do
      @gateway.stub(:ssl_post).and_return(File.read(File.join(fixture_path, "iats", "iats_create_response.html")))
      response = @gateway.create_customer(@amount, @credit_card, @options)
      @customer_code = response.params["customer_code"]
      @gateway.stub(:ssl_post).and_return(File.read(File.join(fixture_path, "iats", "iats_purchase_response.html")))
    end
    it "should return a Response" do
      response = @gateway.purchase_with_customer_code(@amount, @customer_code, @options)
      response.class.should == ActiveMerchant::Billing::Response
    end
    it "should be successful" do
      response = @gateway.purchase_with_customer_code(@amount, @customer_code, @options)
      response.success?.should == true
      response.authorization.should_not be_blank
    end
  end
end
