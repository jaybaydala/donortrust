class CreateIendProfiles < ActiveRecord::Migration
  def self.up
    create_table :iend_profiles do |t|
      t.references :user 
      t.boolean :location
      t.boolean :gifts_given
      t.boolean :gifts_given_amount
      t.boolean :gifts_received
      t.boolean :number_of_projects_funded
      t.boolean :amount_funded
      t.boolean :lives_affected
      t.boolean :list_projects_funded
      
      t.timestamps
    end
  end

  def self.down
    drop_table :iend_profiles
  end
end
