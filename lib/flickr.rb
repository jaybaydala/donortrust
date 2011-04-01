class Flickr
  DT_KEY = "dce9d80477ea833b9dd029bc5f0eceea"
  def initialize_with_key(api_key=nil, email=nil, password=nil)
    api_key = Flickr::DT_KEY if api_key.nil?
    initialize_without_key(api_key, email, password)
    @host="http://api.flickr.com"
    @activity_file='flickr_activity_cache.xml'
  end
  alias_method_chain :initialize, :key
end
