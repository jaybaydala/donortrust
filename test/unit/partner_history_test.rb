require File.dirname(__FILE__) + '/../test_helper'

class PartnerHistoryTest < Test::Unit::TestCase
  fixtures :partner_histories
  
  def create_instance(overrides = {})
    opts = {
      :id => 1,
      :partner_id => 1,
      :name => "name",
      :description => "description",
      :partner_type_id => 1,
      :partner_status_id => 1,
      :created_on => "2007-01-01 01:00:00"
    }.merge(overrides)
    
    PartnerHistory.new(opts)    
  end

  # Replace this with your real tests.
  def test_cant_create_instance
    assert_valid(create_instance)
  end
  
end
