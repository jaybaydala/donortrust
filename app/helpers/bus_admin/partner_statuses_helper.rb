module BusAdmin::PartnerStatusesHelper
  
  def description_column(record)
    SuperRedCloth.new(record.description).to_html
  end
  
end
