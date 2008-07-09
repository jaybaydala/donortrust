xml.instruct! :xml, :version => "1.0" , :encoding=>"UTF-8" 
xml.rss(:version => "2.0") do
  xml.channel do
    xml.title(@campaign.name)
    xml.link("http://www.christmasfuture.com/#{@campaign.short_name}")
    xml.description(@campaign.description)
    
    
    #xml.pubDate(@feed.pub_date)
    #xml.language(@feed.language)
    #xml.copyright(@feed.copyright)
    
    for news_item in @campaign.news_items
      xml.item do
        xml.title(news_item.subject)
        xml.description(news_item.content) 
        xml.link(dt_news_item_path(@campaign)) 
        xml.pubDate(news_item.created_at)
        #xml.comments(element.comments)
       end
    end
  end
end
