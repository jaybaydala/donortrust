module BusAdmin::GroupsHelper
  
  def public_column(record)
    result = "Yes"
    unless record.public 
      result = "No"   
    end
  return result
end

  def description_column(record)
    if record.description!= nil 
      SuperRedCloth.new(record.description).to_html
    end
  end  
end
