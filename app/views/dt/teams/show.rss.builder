xml.instruct! :xml, :version => "1.0" , :encoding=>"UTF-8" 
xml.rss(:version => "2.0") do
  xml.channel do
    xml.title(@team.name)
    xml.link("http://www.christmasfuture.com/#{@team.campaign.short_name}/team/#{@team.short_name}")
    #xml.description(@team.description)
    
    
    #xml.pubDate(@feed.pub_date)
    #xml.language(@feed.language)
    #xml.copyright(@feed.copyright)
    
    for news_item in @team.news_items
      xml.item do
        xml.title(news_item.subject)
        xml.description(news_item.content) 
        xml.link(dt_news_item_path(@team)) 
        xml.pubDate(news_item.created_at)
        #xml.comments(element.comments)
       end
    end
  end
end