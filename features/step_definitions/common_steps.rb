Before do
  Project.create!(:name => Faker::Lorem.words.join(' '), :slug => 'unallocated')
  Project.create!(:name => Faker::Lorem.words.join(' '), :slug => 'admin')
end

Before do
  %w{Continent Country City}.each{|t| Factory(:place_type, :name => t) }
  ['Canada', 'United States of America'].each {|t| Factory(:place, :name => t, :place_type_id => PlaceType.country.id) }
end
