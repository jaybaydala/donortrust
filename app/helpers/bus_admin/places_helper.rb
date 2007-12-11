module BusAdmin::PlacesHelper
  
def file_form_column(record, input_name)
    file_column_field 'record', :file
  end

  def file_column(record)
    record.file ?  link_to(File.basename(record.file), url_for_file_column(record, 'file'), :popup => true) : "-" 
  end
      
  def description_column(record)
    if record.description != nil 
      RedCloth.new(record.description).to_html
    end
  end
  
end
