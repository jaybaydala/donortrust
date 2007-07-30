module BusAdmin::IndicatorMeasurementsHelper

  def frequency_type_id_column(record)     
    record.frequency_types = FrequencyType.find :all, :conditions => ["active > ?", 0] 
  end 
end
