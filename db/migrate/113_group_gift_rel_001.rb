class GroupGiftRel001 < ActiveRecord::Migration
  def self.up
    create_table :group_gifts do |t|
        t.column :first_name, :string
        t.column :last_name, :string
        t.column :email, :string   
        t.column :sent, :boolean   
      end
      if (ENV['RAILS_ENV'] == 'development')
        directory = File.join(File.dirname(__FILE__), "dev_data")
        Fixtures.create_fixtures(directory, "group_gifts") if File.exists? "#{directory}/group_gifts.yml"
    end
  end

  def self.down
     drop_table :group_gifts
  end
end
