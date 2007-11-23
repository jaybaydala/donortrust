module BusAdmin::MillenniumGoalsHelper
  def description_column(record)
    if record.description != nil 
      RedCloth.new(record.description).to_html
    end
  end  
end
