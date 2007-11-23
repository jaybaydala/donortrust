class ProjectYouTubeChangeYouTubeId < ActiveRecord::Migration
  def self.up
    rename_column(:project_you_tube_videos, :you_tube_video_id, :you_tube_id)
  end

  def self.down
    rename_column(:project_you_tube_videos, :you_tube_id, :you_tube_video_id)
  end
end

