module Iend::UsersHelper
  def preferred_sector_options
    Sector.all.map{|s| ["#{image_tag('icons/sector-'+s.name.parameterize+'.png', :alt => '')}<br>#{s.name}".html_safe, s.id] }
  end

  def display_add_as_friend_button
    if logged_in? && @user != current_user && !current_user.friends_with?(@user)
      link_to "+ Add as friend", iend_user_friendships_path(:user_id => current_user.id, :friend_id => @user.id), :id => "add_as_friend", :method => :post, :class => "smallbutton"
    end
  end
end
