class IendProfile < ActiveRecord::Base
  belongs_to :user

  define_index do
    indexes [user(:first_name), user(:last_name)], :as => :user_name
    indexes [user(:country), user(:province), user(:city)], :as => :user_location

    has user_id
    has created_at
    has updated_at
    has preferred_poverty_sectors
    has user.preferred_sectors.sector_id, :as => :sector_ids
  end

  def formatted_location
    [user.city, user.province].compact.delete_if{ |x| x.empty? }.join(', ') if location?
  end

  def formatted_name
    (name? && user.full_name.present?) ? user.full_name : "Anonymous"
  end

  def formatted_sectors
    user.sectors.map(&:name).join(', ') if preferred_poverty_sectors?
  end

end