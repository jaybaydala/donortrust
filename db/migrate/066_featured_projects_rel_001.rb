class FeaturedProjectsRel001 < ActiveRecord::Migration
  def self.up
    create_table :featured_projects do |t|
      t.column :project_id,             :int
      t.column :created_at,             :datetime
      t.column :updated_at,             :datetime
    end
  end

  def self.down
    drop_table :featured_projects
  end
end
