class ProjectsSectorsRel001 < ActiveRecord::Migration
  def self.up
    create_table :projects_sectors, :id => false do |t|
      t.column :project_id, :int
      t.column :sector_id, :int
    end

    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "projects_sectors") if File.exists? "#{directory}/projects_sectors.yml"
    end
  end

  def self.down
    drop_table :projects_sectors
  end
end
