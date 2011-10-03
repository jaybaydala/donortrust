# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_donortrustfe_session_id',
  :secret      => '4000cc1a0b91489bd5eb5b3ef9ccd2f250e6a50ebb11c100e24d74dceba8a73df871a292f89a2f2a93cce98e4b0f91e50ccc626fd6d2cee640696fcff08ae597'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
