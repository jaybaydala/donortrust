Given /a pre-populated database/ do
  %w{Continent Country State District Region City}.each {|s| Factory(:place_type, :name => s) }
  ['Canada', 'United States of America'].each { |s| Factory(:place, :name => s, :place_type_id => PlaceType.country.id) }
end