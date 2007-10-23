module Dt::PlacesHelper
  def country_select_options
    priority_countries = ['Canada', 'United States of America']
    countries = Place.find(:all, :conditions => { :place_type_id => 2 }, :select => :name, :order => :name)
    starting_options = [['Choose a Country...', '']]
    @countries = []
    countries.each do |country|
      starting_options << [country.name, country.name] if priority_countries.include?(country.name)
      @countries << [country.name, country.name] unless priority_countries.include?(country.name)
    end
    @countries = starting_options.concat(@countries)
    @countries
  end
end