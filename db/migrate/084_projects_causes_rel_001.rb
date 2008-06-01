class ProjectsCausesRel001 < ActiveRecord::Migration
  def self.up
    create_table :causes_projects,  :id => false do |t|
      t.column :cause_id,     :integer
      t.column :project_id,    :integer   
    end
  end
  def self.down
    drop_table :causes_projects
  end
end
