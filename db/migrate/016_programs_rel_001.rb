require 'active_record/fixtures'
class ProgramsRel001 < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
      t.column :name, :string, :null => false
      t.column :contact_id, :string, :null => false
      t.column :note, :text
      t.column :blog_url, :string
      t.column :rss_feed_id, :integer
      t.column :deleted_at, :datetime
      t.column :version, :integer
    end # programs
    
     Program.create_versioned_table
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "programs")
    end
  end
  
  def self.down
    drop_table :programs
    Program.drop_versioned_table
  end
end