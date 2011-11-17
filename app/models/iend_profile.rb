class IendProfile < ActiveRecord::Base
  belongs_to :user

  define_index do
    indexes [user(:first_name), user(:last_name)], :as => :user_name

    has user_id
    has created_at
    has updated_at
    has name, :as => :public_name
    has preferred_poverty_sectors
    has user.preferred_sectors.sector_id, :as => :sector_ids
    has list_projects_funded
    has user.investments.project_id, :as => :funded_project_ids
  end

  def formatted_location
    [user.city, user.province].compact.delete_if{ |x| x.empty? }.join(', ') if location?
  end

  def formatted_name
    (name? && user.full_name.present?) ? user.full_name : "Anonymous"
  end

  def preferred_poverty_sectors
    user.sectors.map(&:name).join(', ') if preferred_poverty_sectors?
  end

  def lives_affected
    user.projects_funded.inject(0){|sum,p| sum += p.lives_affected.to_i } if lives_affected?
  end

  def gifts_given
    user.gifts.size if gifts_given?
  end

  def gifts_given_amount
    user.gifts.sum(:amount) if gifts_given_amount?
  end

  def gifts_received
    user.orders.count(:conditions => "gift_card_payment_id IS NOT NULL") if gifts_received?
  end

  def projects_funded
    user.projects_funded.size if list_projects_funded?
  end

  def projects_funded_amount
    user.investments.sum(:amount) if amount_funded?
  end

end