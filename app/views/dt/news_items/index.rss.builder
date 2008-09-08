xml.instruct! :xml, :version => "1.0" , :encoding=>"UTF-8" 
xml.rss(:version => "2.0") do
  xml.channel do
    xml.title @postable.name
    xml.link link_to([:dt,@postable,@news_items])
    #xml.description @news_item.content
    #xml.pubDate(@feed.pub_date)
    #xml.language(@feed.language)
    #xml.copyright(@feed.copyright)
    
    for news_item in @news_items
      xml.item do
        xml.title news_item.subject
        xml.description news_item.content
        xml.pubDate news_item.created_at
       end
    end
  end
end