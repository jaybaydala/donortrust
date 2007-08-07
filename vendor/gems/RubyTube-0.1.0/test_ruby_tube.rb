require 'ruby_tube'
require 'test/unit'

class MockRubyTube < RubyTube
  #@@data = eval(DATA.read)
  #def _get_response(url)
  #  raise "no data for #{url.inspect}" unless @@data.has_key? url 
  #  return REXML::Document.new(@@data[url])
  #end
end

class TestRubyTube < Test::Unit::TestCase

  def setup
    @video_id = '7fnicAxULBU'
    @ruby_tube = MockRubyTube.new('BayCH1FukEw')
  end
  
  ##### video test
  
  def test_find_video
    video = @ruby_tube.get_video(@video_id)
    assert_not_nil video
    assert_equal video.title, 'www.ChristmasFuture.org - End Poverty'
    assert_equal video.tags, 'christmas future charity non-profit MDG international development millennium goals promise poverty aid everyday people'
    assert_not_nil video.comments
    assert_not_nil video.comments[0]
    assert_not_nil video.channels
    assert_not_nil video.channels[0]
  end
  
  def test_find_videos_by_popoular
    videos1 = @ruby_tube.list_popular("all")
    assert_not_nil videos1
    videos2 = @ruby_tube.list_popular("day")
    assert_not_nil videos2
    videos3 = @ruby_tube.list_popular("week")
    assert_not_nil videos3
    videos4 = @ruby_tube.list_popular("month")
    assert_not_nil videos4
    assert_not_equal videos1, videos2
    assert_not_equal videos2, videos3
    assert_not_equal videos3, videos4
    assert_not_equal videos4, videos1
  end
  
  
  
  def test_find_videos
    videos = @ruby_tube.list_by_tag('video',1,20)
    assert_equal videos.size, 20 # lame test I know...
  end
  
  def test_find_videos_by_playlist
    videos = @ruby_tube.list_by_playlist('1E49C0263A535A1B',1,20)
    assert_equal videos[0].title, 'Minneapolis Bridge Collapse Raw News Breaking'
  end
  
  def test_find_videos_by_user
    videos = @ruby_tube.list_by_user('jaybaydala')
    for video in videos
      assert_equal video.author, 'jaybaydala'
    end
  end
  
  def test_find_videos_by_featured
    videos = @ruby_tube.list_featured
    assert_equal videos.size, 100 # this is the only test I could think of, ensuring that we return 100 videos. contrary to the you_tube api it appears to return 100 videos.
  end
  
  def test_find_video_with_channel
    video = @ruby_tube.get_video('93R_CdZuacE')
    assert_not_nil video.channels
  end
  
  def test_find_by_cateogry_and_Tag
    videos1 = @ruby_tube.list_by_category_and_tag("video","Films & Animation",1,2)
    assert_not_nil videos1
    puts videos1[0].title
    videos1 = @ruby_tube.list_by_category_and_tag("video","Autos & Vehicles",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","Comedy",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","Entertainment",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","Music",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","News & Politics",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","People & Blogs",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","Pets & Animals",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","People & Blogs",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","How-to & DIY",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","Sports",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","Travel & Places",1,20)
    assert_not_nil videos1
    videos1 = @ruby_tube.list_by_category_and_tag("video","Gadgets & Games",1,20)
    assert_not_nil videos1
  end
  
  def test_embedded_url
    assert_equal @ruby_tube.get_video(@video_id).embed, 
      "<object width='425' height='350'><param name='movie' value='http://www.youtube.com/v/7fnicAxULBU'></param><param name='wmode' value='transparent'></param><embed src='http://www.youtube.com/v/7fnicAxULBU' type='application/x-shockwave-flash' wmode='transparent' width='425' height='350'></embed></object>"
  end
  
end