Before('@omniauth_test') do
  OmniAuth.config.test_mode = true

  # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
  OmniAuth.config.mock_auth[:facebook] = YAML.load_file(Rails.root.join('spec', 'fixtures', 'authentications', 'facebook.yml'))
end

After('@omniauth_test') do
  OmniAuth.config.test_mode = false
end
