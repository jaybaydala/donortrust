class ProjectYouTubeChangeYouTubeIdType < ActiveRecord::Migration
  def self.up
    change_column(:project_you_tube_videos, :you_tube_id, :string) 
  end

  def self.down
    change_column(:project_you_tube_videos, :you_tube_id, :integer) 
    
  end
end

