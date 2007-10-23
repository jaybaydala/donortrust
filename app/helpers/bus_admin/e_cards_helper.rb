module BusAdmin::ECardsHelper
  
  def small_form_column(record, input_name)
    file_column_field 'record', :small
  end
  def medium_form_column(record, input_name)
    file_column_field 'record', :medium
  end
  def large_form_column(record, input_name)
    file_column_field 'record', :large
  end
  def printable_form_column(record, input_name)
    file_column_field 'record', :printable
  end

  def file_column(record)
    record.file ?  link_to(File.basename(record.file), url_for_file_column(record, 'file'), :popup => true) : "-" 
  end
end