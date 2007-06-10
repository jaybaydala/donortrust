class CreateUrbanCentreRel001 < ActiveRecord::Migration
  def self.up
    create_table :urban_centres, :force => true do |t|
    end
  end

  def self.down
    drop_table :urban_centres
  end
end
