module BusAdmin::GroupsHelper
  
  def public_column(record)
    result = "Yes"
    unless record.public 
      result = "No"   
    end
  return result
  end
end
