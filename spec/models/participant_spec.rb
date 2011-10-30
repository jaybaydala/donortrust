require File.dirname(__FILE__) + '/../spec_helper'

describe Participant do
  before do
    @participant = Factory(:participant)
  end

  it { should belong_to(:user) }
  it { should belong_to(:campaign) }

end