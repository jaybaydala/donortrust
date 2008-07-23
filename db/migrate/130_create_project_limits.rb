class CreateProjectLimits < ActiveRecord::Migration
  def self.up
    create_table :project_limits do |t|
      t.references :campaign
      t.references :project

      t.timestamps
    end
  end

  def self.down
    drop_table :project_limits
  end
end
