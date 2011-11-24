require File.dirname(__FILE__) + '/../spec_helper'

describe CartLineItem do
  let(:cart) { Cart.create }
  let(:investment) { Factory.build(:investment, :amount => 10) }
  subject { Factory(:cart_line_item, { :cart => cart, :item => investment }) }

  it { should belong_to :cart }
  it { should validate_presence_of :cart_id }
  it { should validate_presence_of :item }

  describe "#item" do
    specify { subject.item.class.should == Investment }
  end
end