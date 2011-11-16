module Iend::UsersHelper
  def preferred_sector_options
    Sector.all.map{|s| ["#{image_tag('icons/sector-'+s.name.parameterize+'.png', :alt => '')}<br>#{s.name}".html_safe, s.id] }
  end

  def show_add_friend_button?(user)
    return true if !logged_in?
    user != current_user && !current_user.friends_with?(user)
  end
end
