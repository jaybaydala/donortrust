OmniAuth.config.path_prefix = '/dt/auth'

omniauth_config = YAML.load_file(Rails.root.join('config', 'omniauth.yml'))
ActionController::Dispatcher.middleware.use OmniAuth::Builder do
  provider(:facebook, omniauth_config['facebook']['app_id'], omniauth_config['facebook']['app_secret']) if omniauth_config['facebook'].present?
  provider(:twitter, omniauth_config['twitter']['consumer_key'], omniauth_config['twitter']['consumer_secret']) if omniauth_config['twitter'].present?
  provider(:linked_in, omniauth_config['linked_in']['consumer_key'], omniauth_config['linked_in']['consumer_secret']) if omniauth_config['linked_in'].present?
end
