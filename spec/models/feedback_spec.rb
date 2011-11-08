require File.dirname(__FILE__) + '/../spec_helper'

describe Feedback do
  context "associations" do
    it { should belong_to(:user) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:message) }
  end

  it "should send an email on create" do
    # last parameter is created_at, it should be safe to assume it's ok
    FeedbackMailer.should_receive(:deliver_feedback).with("name", "email", "subject", "message", anything())
    Factory(:feedback, :name => "name", :email => "email", :subject => "subject", :message => "message")
  end
end
