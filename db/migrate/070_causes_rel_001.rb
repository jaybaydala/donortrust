require 'active_record/fixtures'

class CausesRel001 < ActiveRecord::Migration
  def self.up
    create_table :causes do |t|
      t.column :name,         :string
      t.column :description,  :string
      t.column :sector_id,    :int        
      t.column :deleted_at,   :datetime
    end # causes

    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "causes") if File.exists? "#{directory}/causes.yml"
    end
  end

  def self.down
      drop_table :causes
  end
end