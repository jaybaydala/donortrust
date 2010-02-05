class Report < ActiveRecord::Base
  attr_accessor :report_type, :gift, :start_date, :end_date

  def initialize(attributes = {})
    @report_type = attributes[:report_type] || 'gift_report'
  end
end
