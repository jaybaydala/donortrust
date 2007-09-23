class Dt::PlaceSearchesController < DtApplicationController
  def create
    conditions = {}
    %w( name, place_type_id, parent_id ).each do |f|
      conditions[f.to_sym] = params[f.to_sym] if params[f.to_sym]
    end
    places = Place.find(:all, :limit => 10, :conditions => conditions)
    pp places.to_json
    respond_to do |format|
      format.js
    end
  end
end
