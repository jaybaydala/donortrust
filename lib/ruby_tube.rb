class RubyTube
  DT_KEY =  "BayCH1FukEw"
  def initialize_with_key(api_key)
    api_key = RubyTube::DT_KEY if api_key.nil?
    initialize_without_key(api_key)
  end
  alias_method_chain :initialize, :key
end
