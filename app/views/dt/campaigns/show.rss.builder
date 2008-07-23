xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title("#{@campaign.name} Recent News")
    xml.link("http://www.christmasfuture.com/#{@campaign.short_name}")
    for news_item in @campaign.news_items
      xml.item do
        xml.title(news_item.subject)
        xml.description(news_item.content) 
        xml.link(dt_news_item_path(@team)) 
        xml.pubDate(news_item.created_at)
      end
    end
  end
end