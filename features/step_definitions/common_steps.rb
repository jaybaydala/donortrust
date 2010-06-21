Given /a pre-populated database/ do
  %w{Continent Country State District Region City}.each {|s| PlaceType.make :name => s }
  ['Canada', 'United States of America'].each { |s| Place.make :name => s, :place_type_id => PlaceType.country.id }
end