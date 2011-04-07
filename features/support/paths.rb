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
      '/dt'
    when /the new account page/
      new_dt_account_path
    when /the accounts page/
      dt_accounts_path
    when /my account page/
      dt_account_path(current_user)
    when /the sign up page/
      '/dt/signup'
    when /redisplayed sign up page/
      '/dt/accounts'
    when /the login page/
      '/dt/login'
    when /the redisplayed login page/
      '/dt/session'
    when /the authentications page/
      dt_authentications_path
    when /the (.*) team page/
      dt_team_path(Team.find_by_short_name($1))
    when /the (.*) campaign page/
      dt_campaign_path(Campaign.find_by_short_name($1))

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
