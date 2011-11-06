module Iend::UsersHelper
  def preferred_sector_options
    Sector.all.map{|s| ["#{image_tag('icons/sector-'+s.name.parameterize+'.png', :alt => '')}<br>#{s.name}".html_safe, s.id] }
  end

  def display_add_as_friend_button
    unless @user == current_user
      button_to "Add as friend", "", :id => "add_as_friend"
    end
  end
end
