module BusAdmin::UrbanCentresHelper
  
  def blog_name_column(record)
      link_to(record.blog_name, record.blog_url)
  end
  
  def blog_url_column(record)
      link_to(record.blog_url, record.blog_url)
  end
  def rss_url_column(record)
      link_to(record.rss_url, record.rss_url)
  end
end
