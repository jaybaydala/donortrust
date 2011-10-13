require File.dirname(__FILE__) + '/../spec_helper'

describe IendProfile do
  let(:iend_profile) { Factory(:iend_profile) }
  it { should belong_to :user }
end