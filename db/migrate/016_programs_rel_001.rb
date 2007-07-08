require 'active_record/fixtures'

class ProgramsRel001 < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
      t.column :name, :string, :null => false
      t.column :contact_id, :string, :null => false
    end # programs
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "programs")
    end
  end
  
  def self.down
    drop_table :programs
  end
end