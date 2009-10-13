xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title("#{@participant.user.full_name}'s Recent News For #{@participant.team.campaign.name}")
    xml.link("http://www.uend.org/")
    for news_item in @participant.news_items
      xml.item do
        xml.title(news_item.subject)
        xml.description(news_item.content) 
        xml.link(dt_news_item_path(news_item)) 
        xml.pubDate(news_item.created_at)
      end
    end
  end
end