class YouTubeVideosRel001 < ActiveRecord::Migration
  def self.up
    create_table "you_tube_videos", :force => true do |t|
      t.column :you_tube_reference,     :string
      t.column :keywords,               :string
      t.column :comments,               :string
    end
  end

  def self.down
    drop_table "you_tube_videos"
  end
end
