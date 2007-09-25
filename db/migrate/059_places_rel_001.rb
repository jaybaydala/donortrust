class PlacesRel001 < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.column :name,                 :string
      t.column :place_type_id,        :int
      t.column :parent_id,            :int
      t.column :description,          :text
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "places") if File.exists? "#{directory}/places.yml"
    end
  end

  def self.down
    drop_table :places
  end
end
