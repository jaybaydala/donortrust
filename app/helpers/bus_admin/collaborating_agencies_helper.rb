module BusAdmin::CollaboratingAgenciesHelper
  def responsibilities_column(record)
    if record.responsibilities!= nil 
      SuperRedCloth.new(record.responsibilities).to_html
    end
  end
end
