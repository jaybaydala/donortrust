require File.dirname(__FILE__) + '/../spec_helper'

describe Facebook do
  let (:authentication) { Factory(:authentication, :provider => "facebook") }
  let (:user) { authentication.user }
  let (:facebook) { Facebook.new(user) }

  context "initialization" do
    it "should require an argument" do
      lambda{ Facebook.new }.should raise_exception(ArgumentError)
    end
    
    it "should require a user" do
      lambda{ Facebook.new(Factory(:project)) }.should raise_exception(ArgumentError)
    end
  end

  context "access_token" do
    it "should return the facebook provider token" do
      facebook.access_token.should eql(authentication.token)
    end

    it "should return nil is there's no authentication" do
      authentication.destroy
      facebook.access_token.should be_nil
    end
  end

  context "uid" do
    it "should return the facebook provider uid" do
      facebook.uid.should eql(authentication.uid)
    end

    it "should return nil is there's no authentication" do
      authentication.destroy
      facebook.uid.should be_nil
    end
  end

  context "post" do
    let (:oauth_client) { mock(OAuth2::Client) }

    before do
      OAuth2::Client.stub(:new).and_return(oauth_client)
      @good_return = {:id => 123198234897}
      oauth_client.stub(:request).and_return(@good_return)
    end

    it "should post the messages with the params" do
      oauth_client.should_receive(:request).with(:post, "/#{facebook.uid}/feed", { :params => { :message => "hithere", :access_token => facebook.access_token }})
      facebook.post(:message => "hithere")
    end

    it "returns the post id when successful" do
      facebook.post(:message => "hithere").should eql(@good_return)
    end

    it "ignores non-valid params" do
      oauth_client.should_receive(:request).with(:post, "/#{facebook.uid}/feed", { :params => { :message => "hithere", :access_token => facebook.access_token }})
      facebook.post(:message => "hithere", :foo => 'bar', :baz => "que")
    end
  end
end