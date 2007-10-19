module BusAdmin::MilestonesHelper
  def description_column(record)
    SuperRedCloth.new(record.description).to_html
  end
end
