class CreateIendProfiles < ActiveRecord::Migration
  def self.up
    create_table :iend_profiles do |t|
      t.references :user 
      t.boolean :location, :default => true
      t.boolean :gifts_given, :default => true
      t.boolean :gifts_given_amount, :default => true
      t.boolean :gifts_received, :default => true
      t.boolean :number_of_projects_funded, :default => true
      t.boolean :amount_funded, :default => true
      t.boolean :lives_affected, :default => true
      t.boolean :list_projects_funded, :default => true
      t.boolean :show_uend_amount, :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :iend_profiles
  end
end
