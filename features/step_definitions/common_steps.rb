Before do
  Project.unallocated_project || Factory.build(:unallocated_project).save
  Project.admin_project || Factory.build(:admin_project).save
end

Before do
  %w{Continent Country City}.each{|t| Factory(:place_type, :name => t) }
  ['Canada', 'United States of America'].each {|t| Factory(:place, :name => t, :place_type_id => PlaceType.country.id) }
end
