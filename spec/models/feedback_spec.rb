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
end
