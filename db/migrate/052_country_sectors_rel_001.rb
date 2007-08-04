class CountrySectorsRel001 < ActiveRecord::Migration
  def self.up
    create_table :country_sectors do |t|
      t.column :country_id, :int
      t.column :sector_id, :int
      t.column :content, :text
    end

    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "country_sectors") if File.exists? "#{directory}/country_sectors.yml"
    end
  end

  def self.down
    drop_table :country_sectors
  end
end
