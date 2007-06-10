class SectorsRel001 < ActiveRecord::Migration
  def self.up
    create_table :sectors, :force => true do |t|
      t.column :sector_name, :string
      t.column :description, :string
     
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "sectors")
    end
  end

  def self.down
    drop_table :sectors
  end
end
