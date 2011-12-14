require File.dirname(__FILE__) + '/../spec_helper'

describe Geolocation do

	IPS = { :CA => '198.103.238.30', :US => '74.125.113.99' }
 
 	describe "#lookup" do
 		it "finds a country code if the ip is cached" do
 			Geolocation.create(:ip_address => IPS[:CA], :country_code => 'NZ')
 			lambda {
	 			code = Geolocation.lookup(IPS[:CA])
	 		}.should_not change(Geolocation, :count)
 		end
 		it "looks up a country code if the ip is not cached" do
 			Geolocation.find_all_by_ip_address(IPS[:CA]).each(&:destroy)
 			lambda {
	 			code = Geolocation.lookup(IPS[:CA])
	 		}.should change(Geolocation, :count).by(1)
 		end
  	it "should not lookup a country code if there is no ip" do
  		Geolocation.lookup(nil)
  	end
 		it "returns a CA country code for a Canadian IP" do
  		code = Geolocation.lookup(IPS[:CA])
  		code.should == 'CA'
  	end
  	it "returns a US country code for a U.S. IP" do
  		code = Geolocation.lookup(IPS[:US])
  		code.should == 'US'
  	end
 	end

 	it "is invalid without an IP" do
 		geo = Geolocation.new(:ip_address => nil)
 		geo.should_not be_valid
 	end

 	it "is invalid without a country code" do
 		geo = Geolocation.new(:country_code => nil)
 		geo.should_not be_valid
 	end

end