omniauth_config = YAML.load_file(Rails.root.join('config', 'omniauth.yml'))

FACEBOOK_APP_ID = omniauth_config['facebook']['app_id'] if omniauth_config['facebook']

# require 'omniauth'
require 'oauth2'
require 'openid/store/filesystem'
ActionController::Dispatcher.middleware.use OmniAuth::Builder do
  provider(:facebook, omniauth_config['facebook']['app_id'], omniauth_config['facebook']['app_secret'], {
    :scope => omniauth_config['facebook']['scope'], 
    :client_options => {
      :ssl => {
        :ca_path => "/etc/ssl/certs"
      }
    }
  }) if omniauth_config['facebook'].present?
  provider(:twitter, omniauth_config['twitter']['consumer_key'], omniauth_config['twitter']['consumer_secret']) if omniauth_config['twitter'].present?
  provider(:linked_in, omniauth_config['linked_in']['consumer_key'], omniauth_config['linked_in']['consumer_secret']) if omniauth_config['linked_in'].present?
  # dedicated openid
  provider :openid, OpenID::Store::Filesystem.new('./tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
end
