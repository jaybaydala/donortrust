require 'csv'
class Report < ActiveRecord::Base
      attr_accessor :gift, :start_date, :end_date

      def initialize(attributes = nil)
      	  @gift = 'gift_report'
	  puts "Initialization run"
      end
end
   
   

  
  
