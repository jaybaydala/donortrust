module BusAdmin::IndicatorMeasurementsHelper

  def frequency_types_column(record)     
    record.frequency_type = FrequencyType.find :all, :conditions => ["active > ?", 0] 
  end 
end
