require File.dirname(__FILE__) + '/../spec_helper'

describe Subscription do
  let(:subscription) { Factory(:subscription) }
  subject { subscription }
  
  context "associations" do
    it { should belong_to(:order) }
    it { should belong_to(:user) }
    it { should have_many(:line_items) }
    it { should have_many(:orders) }
    it { should have_many(:tax_receipts) }
  end

  context "validations" do
    it { should validate_presence_of(:donor_type) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:province) }
    it { should validate_presence_of(:postal_code) }
    it { should validate_presence_of(:country) }
    it { should validate_presence_of(:email) }
    it { should validate_format_of(:email).with(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i) }
  end

  describe "#card_number" do
    before do
      subject.card_number = '4111111111111234'
    end
    its(:card_number) { should == '4111111111111234' }
    it "should return the masked card number when @full_card_number is nil" do
      subscription.full_card_number = nil
      subscription.card_number.should == '1234'
    end
  end

  describe "#orders_for_year" do
    before do
      Timecop.travel(Time.now - 1.year) do
        create_order
        create_order
        create_order(false)
      end
      create_order
      create_order(false)
    end

    context "should only return completed orders for the specified year" do
      specify { subscription.orders_for_year(Date.today.year - 1).count.should == 2 }
      specify { subscription.orders_for_year(Date.today.year).count.should == 1 }
    end
  end

  describe "#yearly_total" do
    before do
      Timecop.travel(Time.now - 1.year) { (1..12).each{ create_order } }
      create_order
    end
    specify { subscription.yearly_total(Date.today.year - 1).should == 60 }
    specify { subscription.yearly_total(Date.today.year).should == 5 }
  end

  describe "#yearly_tax_receiptable_total" do
    context "non-tax_receiptable subscriptions" do
      before do
        subscription.tax_receipt_requested = false
        Timecop.travel(Time.now - 1.year) { (1..12).each{ create_order } }
        create_order
      end
      specify { subscription.yearly_tax_receiptable_total(Date.today.year - 1).should == 0 }
      specify { subscription.yearly_tax_receiptable_total(Date.today.year).should == 0 }
    end
    context "tax_receiptable subscriptions" do
      before do
        subscription.tax_receipt_requested = true
        Timecop.travel(Time.now - 1.year) { (1..12).each{ create_order } }
        create_order
      end
      specify { subscription.yearly_tax_receiptable_total(Date.today.year - 1).should == 60 }
      specify { subscription.yearly_tax_receiptable_total(Date.today.year).should == 5 }
    end
  end

  describe "#create_yearly_tax_receipt" do
    context "non-tax_receiptable subscriptions" do
      before do
        subscription.tax_receipt_requested = false
        Timecop.travel(Time.now - 1.year) { (1..12).each{ create_order } }
      end
      specify { expect{subscription.create_yearly_tax_receipt(Date.today.year - 1)}.to_not change{TaxReceipt.count} }
      specify { subscription.create_yearly_tax_receipt(Date.today.year - 1).should be_nil }
    end
    context "tax_receiptable subscriptions" do
      before do
        subscription.tax_receipt_requested = true
        Timecop.travel(Time.now - 1.year) { (1..12).each{ create_order } }
      end
      specify { expect{subscription.create_yearly_tax_receipt(Date.today.year - 1)}.to change{TaxReceipt.count}.by(1) }
      specify { subscription.create_yearly_tax_receipt(Date.today.year - 1).class.should == TaxReceipt }
      context "after tax receipt is created" do
        before do
          subscription.create_yearly_tax_receipt(Date.today.year - 1)
        end
        let(:tax_receipt) { subscription.tax_receipts.first }
        specify { tax_receipt.amount.should == subscription.yearly_tax_receiptable_total(Date.today.year - 1) }
        specify { tax_receipt.received_on.should == Date.civil(Date.today.year - 1, 12, 31) }
        specify { tax_receipt.order.should be_nil }
      end
      context "for a subscription with non-Canadian subscriber" do
        before do
          subscription.country = "United States"
        end
        specify { expect{subscription.create_yearly_tax_receipt(Date.today.year - 1)}.to_not change{TaxReceipt.count} }
        specify { subscription.create_yearly_tax_receipt(Date.today.year - 1).should be_nil }
      end
      context "with no orders" do
        before do
          Order.destroy_all
        end
        specify { expect{subscription.create_yearly_tax_receipt(Date.today.year - 1)}.to_not change{TaxReceipt.count} }
        specify { subscription.create_yearly_tax_receipt(Date.today.year - 1).should be_nil }
      end
      context "when yearly_tax_receiptable_total == 0" do
        before do
          subscription.stub(:yearly_tax_receiptable_total).and_return(0)
        end
        specify { expect{subscription.create_yearly_tax_receipt(Date.today.year - 1)}.to_not change{TaxReceipt.count} }
        specify { subscription.create_yearly_tax_receipt(Date.today.year - 1).should be_nil }
      end
    end
  end

  def create_order(completed = true)
    order = subscription.prepare_order
    order.update_attributes(:complete => completed)
    order
  end
end
