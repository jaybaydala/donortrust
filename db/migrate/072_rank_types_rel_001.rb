class RankTypesRel001 < ActiveRecord::Migration
  def self.up
    create_table :rank_types do |t|
      t.column :name,           :string
      t.column :description,    :string   
      t.column :deleted_at,     :datetime
      t.column :version,        :integer
    end
    if (ENV['RAILS_ENV'] == 'development')
        directory = File.join(File.dirname(__FILE__), "dev_data")
        Fixtures.create_fixtures(directory, "rank_types") if File.exists? "#{directory}/rank_types.yml"
    end
  end
  def self.down
    drop_table :rank_types
  end
end