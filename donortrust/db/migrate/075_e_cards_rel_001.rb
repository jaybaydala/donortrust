class ECardsRel001 < ActiveRecord::Migration
  def self.up
    create_table :e_cards do |t|
      t.column :name,      :string
      t.column :credit,    :string  
      t.column :small,     :string     
      t.column :medium,    :string     
      t.column :large,     :string     
      t.column :printable, :string     
    end
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "memberships") if File.exists? "#{directory}/e_cards.yml"
    end
  end
  def self.down
    drop_table :e_cards
  end
end
