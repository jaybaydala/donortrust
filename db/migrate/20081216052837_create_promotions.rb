class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.string :name
      t.timestamps
    end

    add_column :gifts, :promotion_id, :integer
    # TODO: Put a foreign key in here

    add_column :investments, :promotion_id, :integer
    execute "ALTER TABLE investments ADD FOREIGN KEY (promotion_id) REFERENCES promotions(id)"
  end

  def self.down
    remove_column :gifts, :promotion_id
    remove_column :investments, :promotion_id
    drop_table :promotions
  end
end
