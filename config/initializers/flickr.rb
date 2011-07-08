if File.exists?(Rails.root.join('config', 'flickr.yml'))
  flickr_config = YAML.load_file(Rails.root.join('config', 'flickr.yml'))
  FlickRaw.api_key = flickr_config['key'] if flickr_config.present? && flickr_config['key'].present?
end