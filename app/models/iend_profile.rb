class IendProfile < ActiveRecord::Base
  belongs_to :user

  define_index do
    indexes [user(:first_name), user(:last_name)], :as => :user_name
    indexes [user(:country), user(:province), user(:city)], :as => :user_location

    has user_id
    has created_at
    has updated_at
  end

  def display_name
    [formatted_name, formatted_location].compact.delete_if{ |x| x.empty? }.join(', ')
  end

  def formatted_location
    return [user.city, user.province, user.country].compact.delete_if{ |x| x.empty? }.join(', ') if location?
  end

  def formatted_name
    return user.full_name if name? && user.full_name.present?
    "Anonymous"
  end

end