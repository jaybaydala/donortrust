class YouTubeVideosRel001 < ActiveRecord::Migration
  def self.up
    create_table "you_tube_videos", :force => true do |t|
      t.column :you_tube_video_ref,     :string
      t.column :message,                :string
    end
  end

  def self.down
    drop_table "you_tube_videos"
  end
end
