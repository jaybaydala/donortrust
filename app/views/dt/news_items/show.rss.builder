xml.instruct! :xml, :version => "1.0" , :encoding=>"UTF-8" 
xml.rss(:version => "2.0") do
  xml.channel do
    xml.title @news_item.subject
    xml.link dt_news_item_path(@news_item)
    xml.description @news_item.content
    
    
    #xml.pubDate(@feed.pub_date)
    #xml.language(@feed.language)
    #xml.copyright(@feed.copyright)
    
    for comment in @news_item.news_comments
      xml.item do
        xml.title comment.author.full_name
        xml.description comment.comment
        xml.pubDate comment.created_at
       end
    end
  end
end