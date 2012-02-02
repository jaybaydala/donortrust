module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/home'
    when /the new account page/
      new_iend_account_path
    when /my account page/
      iend_user_path(current_user || User.last)
    when /my cart page/
      dt_cart_path
    when /my friendships page/
      iend_user_friends_path(current_user || User.last)
    when /my friend's page/
      user = current_user || User.last
      @friend ||= user.friends.first
      iend_user_path(@friend)
    when /the new upowered page/
      new_dt_upowered_path
    when /the order confirmation page/
      # @order ||= Order.last
      dt_checkout_path
    when /the sign up page/
      '/signup'
    when /redisplayed sign up page/
      iend_users_path
    when /the login page/
      '/login'
    when /the redisplayed login page/
      iend_session_path
    when /my|the iend user page/
      iend_user_path(current_user || User.last)
    when /the authentications page/
      iend_authentications_path
    when /the "(.*)" team page/
      dt_team_path(Team.find_by_short_name($1))
    when /the "(.*)" campaign page/
      dt_campaign_path(Campaign.find_by_short_name($1))
    when /the users page/
      iend_users_path
    when /the new gift page/
      new_dt_gift_path
    when /the projects page/
      dt_projects_path

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
