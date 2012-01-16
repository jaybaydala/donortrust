module CommonDataHelpers
  def load_projects
    Factory.build(:unallocated_project).save! unless Project.find_by_slug("unallocated").present?
    Factory.build(:admin_project).save! unless Project.find_by_slug("admin").present?
    Factory.build(:partner_status, :name => "Active").save! unless PartnerStatus.active.present?
  end

  def load_locations
    %w{Continent Country City}.each{|t| PlaceType.find_by_name(t) || Factory(:place_type, :name => t) }
    ['Canada', 'United States of America'].each {|t| Place.find_by_name_and_place_type_id(t, PlaceType.country.id) || Factory(:place, :name => t, :place_type_id => PlaceType.country.id) }
  end

  def load_common_data
    load_projects
    load_locations
  end
end
World(CommonDataHelpers)

Before do
  load_common_data
end
