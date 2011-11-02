class IendProfile < ActiveRecord::Base
  belongs_to :user

  define_index do
    indexes [user(:first_name), user(:last_name), user(:country)], :as => :user

    has user_id
    has created_at
    has updated_at
  end

  def formatted_name
    return user.full_name if name? && user.full_name.present?
    "Anonymous"
  end

end