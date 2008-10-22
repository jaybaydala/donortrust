class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

  protected
  def page_link(page, text, attributes = {})
    if @remote[:special_url] == "checkoutcart" && @remote[:url]
      @remote.delete(:special_url)
      @remote[:url] = url_for_checkoutcart(page, @remote[:url])
    end
    @template.link_to_remote(text, {:url => url_for(page), :method => :get}.merge(@remote), :href => url_for(page))
  end

  def url_for_checkoutcart(page, url)
    "#{url}#{url.match(/\?/) ? "&" : "?"}#{param_name}=#{page}"
  end
end