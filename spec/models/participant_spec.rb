require File.dirname(__FILE__) + '/../spec_helper'

describe Participant do
  it { should belong_to(:user) }
  it { should belong_to(:campaign) }
end