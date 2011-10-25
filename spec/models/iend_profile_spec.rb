require File.dirname(__FILE__) + '/../spec_helper'

describe IendProfile do
  let(:iend_profile) { Factory(:iend_profile) }
  it { should belong_to :user }
  context "should have sane defaults:" do
    %w(name picture location).each do |att|
      its("#{att}?".to_sym) { should be_false }
    end
    %w(preferred_poverty_sectors gifts_given gifts_given_amount gifts_received number_of_projects_funded amount_funded lives_affected list_projects_funded show_uend_amount).each do |att|
      its("#{att}?".to_sym) { should be_true }
    end
  end
end