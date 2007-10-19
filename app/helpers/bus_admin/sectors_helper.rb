module BusAdmin::SectorsHelper
   def description_column(record)
    if record.description!= nil 
      SuperRedCloth.new(record.description).to_html
    end
  end
end
