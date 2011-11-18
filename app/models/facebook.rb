class Facebook
  attr_accessor :user
  # post params
  attr_accessor :message, :picture, :link, :name, :caption, :description, :source

  def initialize(user)
    raise ArgumentError, 'You must pass a user' unless user.class == User
    self.user = user
  end

  class << self
    def admins
      admins = %w(jaybaydala KMMO4)
      admins.push('sterrym') unless Rails.env.production?
      admins
    end

    def app_credentials
      @@app_credentials ||= YAML.load_file(Rails.root.join('config', 'omniauth.yml'))['facebook'].symbolize_keys
    end

    def app_id
      app_credentials[:app_id]
    end
  end

  def post(params={})
    request :post, "/#{uid}/feed", normalize_params(params, %w(message picture link name caption description source))
  end

  def to_param
  end

  def access_token
    @access_token ||= provider.token unless provider.nil?
  end

  def uid
    @uid ||= provider.uid unless provider.nil?
  end

  private
    def request(action, path, params)
      client = OAuth2::Client.new(app_id, app_secret, :site => 'https://graph.facebook.com/', :raise_errors => false, :parse => :query, :parse_json => true, :ssl => { :ca_path => "/etc/ssl/certs" })
      client.request(action, path, :params => params.merge({ :access_token => access_token }))
    end

    def normalize_params(params, allowed_params)
      Hash[ *allowed_params.map do |k|
        [k.to_sym, params[k.to_sym]] if params[k.to_sym].present?
      end.select(&:present?).flatten ]
    end
  
    def provider
      @provider ||= user.authentications.facebook.first
    end
  
    def app_credentials
      self.class.app_credentials
    end
  
    def app_id
      app_credentials[:app_id]
    end
  
    def app_secret
      app_credentials[:app_secret]
    end
end