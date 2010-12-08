class User < ActiveRecord::Base
  generator_for :login, :start => 'test@domain.com' do |prev|
    user, domain = prev.split('@')
    user.succ + '@' + domain
  end
  generator_for :first_name, "First"
  generator_for :last_name, "Last"
  generator_for :display_name, "First L."
  generator_for :country, "Canada"
  generator_for :password, "password"
  generator_for :password_confirmation, "password"
  generator_for :terms_of_use, "1"
end