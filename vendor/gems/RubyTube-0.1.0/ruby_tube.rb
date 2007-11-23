# = RubyTube
# A Simple Interface into the YouTube API
#   
# Author::    Joe Gaudet
# Copyright:: Copyright (c) 2007 Joe Gaudet <joe@obsidian-edge.ca>
# License::   GPL
# 
# USAGE:
# 
#
# TODO:
#
# Implement the following API Functions
#
# User Information
# youtube.users.get_profile
# youtube.users.list_favorite_videos
# youtube.users.list_friends (with paging)
# add comment/channel handling of some sort didn't seem critical yet.
#
# Video Viewing
# youtube.videos.get_details # add error handling
# youtube.videos.list_by_tag (with paging) # add error handling
# youtube.videos.list_by_user (with paging) # add error handling
# youtube.videos.list_featured # add error handling 
# youtube.videos.list_by_playlist (with paging) # add error handling
# youtube.videos.list_popular # add error handling # add error handling
# youtube.videos.list_by_category_and_tag (with paging) # add error handling
#

require 'rubygems'
require 'net/http'
require 'xmlsimple'

# Flickr client class. Requires an API key, and optionally takes an email and password for authentication
class RubyTube

  attr_accessor :api_key

  def initialize(api_key)
    @api_key = api_key
  end
  
  # implementation of get_details
  # returns a new YouTube Video object with the details fields populated
  def get_video(id = nil)
    hash_response = you_tube_method_call("youtube.videos.get_details", "&video_id=#{id}")
    if(hash_response['status'] != 'fail')
      video = Video.new
      video.populate_from_hash_array(hash_response['video_details'][0],id)
      video.populate_comments(hash_response['video_details'][0]['comment_list'][0])
      video.populate_channels(hash_response['video_details'][0]['channel_list'][0])
      return video
    end
  end
  
  # returns a list of videos that match a specific tag  
  def list_by_tag(tag = nil, page = 1, per_page = 20)
    per_page = 100 if per_page > 100 # max per page
    hash_response = you_tube_method_call("youtube.videos.list_by_tag", "&tag=#{tag.gsub(' ','%20')}", "&page=#{page}" , "&per_page=#{per_page}")
    videos = Array.new
    video_list = hash_response['video_list'][0]['video']
    for i in 0...video_list.size
      video = Video.new
      video.populate_from_hash(video_list[i])
      videos.push(video)
    end
    return videos
  end
  
  # returns a list of videos that mathc a specific user
  def list_by_user(user_name = nil, page = 1, per_page = 20)
    per_page = 100 if per_page > 100 # max per page
    hash_response = you_tube_method_call("youtube.videos.list_by_user", "&user=#{user_name}", "&page=#{page}" , "&per_page=#{per_page}")
    get_array_of_videos_from_hash_array(hash_response)
  end

  
  # returns a list of videos that are currently featured
  def list_featured
    hash_response = you_tube_method_call("youtube.videos.list_featured")
    get_array_of_videos_from_hash_array(hash_response)
  end
  
  #returns a list of videos by playlist
  def list_by_playlist(id=nil, page = 1, per_page = 20)
    hash_response = you_tube_method_call("youtube.videos.list_by_playlist", "&id=#{id}", "&page=#{page}" , "&per_page=#{per_page}")
    get_array_of_videos_from_hash_array(hash_response)
  end
  
  #returns a list of popular videos
  def list_popular(time_range="all")
    hash_response = you_tube_method_call("youtube.videos.list_popular", "&time_range=#{time_range}")
    get_array_of_videos_from_hash_array(hash_response)
  end
  
  #returns a list of videos by category and tag
  # Films & Animation: 1 
  # Autos & Vehicles: 2 
  # Comedy: 23 
  # Entertainment: 24 
  # Music: 10 
  # News & Politics: 25 
  # People & Blogs: 22 
  # Pets & Animals: 15 
  # How-to & DIY: 26 
  # Sports: 17 
  # Travel & Places: 19 
  # Gadgets & Games: 20
  def list_by_category_and_tag(tag=nil,category=nil, page = 1, per_page = 20)
    category_id = case
      when category == "Films & Animation" :   1
      when category == "Autos & Vehicles"  :   2
      when category == "Comedy"            :   23
      when category == "Entertainment"     :   24
      when category == "Music"             :   10
      when category == "News & Politics"   :   25
      when category == "People & Blogs"    :   22
      when category == "Pets & Animals"    :   15
      when category == "How-to & DIY"      :   26
      when category == "Sports"            :   17
      when category == "Travel & Places"   :   19
      when category == "Gadgets & Games"   :   20
      else return;
      end
      per_page = 100 if per_page > 100 # max per page
      hash_response = you_tube_method_call("youtube.videos.list_by_category_and_tag", "&category_id=#{category_id}","&tag=#{tag.gsub(' ','%20')}", "&page=#{page}" , "&per_page=#{per_page}")
      get_array_of_videos_from_hash_array(hash_response)
  end
  
  def get_array_of_videos_from_hash_array(hash_response)
    videos = Array.new
    if(hash_response['status'] != 'fail')
      video_list = hash_response['video_list'][0]['video']
      if video_list == nil
        return videos
      end
      for i in 0...video_list.size
        video = Video.new
        video.populate_from_hash_array(video_list[i])
        videos.push(video)
      end
    end # appending error codes will go here....
    return videos
  end
  
  #returns a hash table of what ever method call sent out.
  def you_tube_method_call(method = nil, *arguments)
    url = "http://www.youtube.com/api2_rest?method=#{method}&dev_id=#{@api_key}#{arguments.join()}"
    response = Net::HTTP.get_response(URI.parse(url))
    hash_response = XmlSimple.xml_in(response.body[0,response.body.size], { 'ForceArray' => true })
  end
  
  class Video
    attr_accessor :id, :author, :title, :rating_avg, :rating_count, :tags, :description, :upload_time, :length_seconds, :recording_date, :recording_location, :recording_country, :thumbnail_url, :embed_status, :comments, :channels
    
    def initialize()
    end
  
    # returns the embedded url
    def embed
      "<object width='425' height='350'><param name='movie' value='http://www.youtube.com/v/#{@id}'></param><param name='wmode' value='transparent'></param><embed src='http://www.youtube.com/v/#{@id}' type='application/x-shockwave-flash' wmode='transparent' width='425' height='350'></embed></object>"
    end
  
    
    def populate_from_hash_array(video_details,*id)
        @author             = video_details['author'][0]              if video_details['author']
        @title              = video_details['title'][0]               if video_details['title']
        @rating_avg         = video_details['rating_avg'][0]          if video_details['rating_avg']
        @rating_count       = video_details['rating_count'][0]        if video_details['rating_count']
        @tags               = video_details['tags'][0]                if video_details['tags']
        @description        = video_details['description'][0]         if video_details['description']
        @update_time        = video_details['upload_time'][0]         if video_details['upload_time']
        @length_seconds     = video_details['length_seconds'][0]      if video_details['length_seconds']
        @recording_date     = video_details['recording_date'][0]      if video_details['recording_date']
        @recording_location = video_details['recording_location'][0]  if video_details['recording_location']
        @comment_count      = video_details['comment_count'][0]       if video_details['comment_count']
        @recording_country  = video_details['recording_country'][0]   if video_details['recording_country']
        @thumbnail_url      = video_details['thumbnail_url'][0]       if video_details['thumbnail_url']
        @embed_status       = video_details['embed_status'][0]        if video_details['embed_status']
        @id = video_details["id"]
        @id ||= id 
        
        
      #end #perhaps chuck some exceptions here...
    end
    
    def populate_from_hash(video_details,*id)
        @author             = video_details['author']
        @title              = video_details['title']
        @rating_avg         = video_details['rating_avg']
        @rating_count       = video_details['rating_count']
        @tags               = video_details['tags']
        @description        = video_details['description']
        @upload_time        = video_details['upload_time']
        @length_seconds     = video_details['length_seconds']
        @recording_date     = video_details['recording_date']
        @recording_location = video_details['recording_location']
        @recording_country  = video_details['recording_country']
        @thumbnail_url      = video_details['thumbnail_url']
        @embed_status       = video_details['embed_status']        
        @comment_count      = video_details['comment_count']
        @id = video_details["id"]
        @id ||= id
        
      #end #perhaps chuck some exceptions here...
    end
    
    def populate_comments(comments_hash)
      @comments = Array.new
      if(comments_hash['comment'] != nil)
        if(comments_hash['comment'].size > 0)
          for i in 0...comments_hash['comment'].size
            @comments.push(Comment.new(comments_hash['comment'][i]))
          end
        end
      end
    end
    
    def populate_channels(channel_hash)
      @channels = Array.new
      if(channel_hash['channel'].size > 0)
        for i in 0...channel_hash['channel'].size
          @channels.push(Channel.new(channel_hash['channel'][i]))
        end
      end
    end
    
    class Comment
      
      attr_accessor :author, :text, :time
      
      def initialize(comment_hash)
        @author = comment_hash['author']
        @text = comment_hash['text']
        @date = comment_hash['time'] # Will eventually be updated to convert to a real date time object
      end
      
      def to_s
        "Author: #{@author.to_s}, \n #{@text.to_s}"
      end
      
    end
    
    class Channel
      attr_accessor :name
      
      def initialize(name)
        @name = name
      end
      
    end
  end
end
