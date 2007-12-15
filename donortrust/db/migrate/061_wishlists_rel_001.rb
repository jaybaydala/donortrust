class WishlistsRel001 < ActiveRecord::Migration
  def self.up
    create_table :wishlists do |t|
      t.column :user_id,      :int
      t.column :project_id,   :int
    end
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "wishlists") if File.exists? "#{directory}/wishlists.yml"
    end
  end

  def self.down
    drop_table :wishlists
  end
end
