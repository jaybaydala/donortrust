class AddPartnerToMeasures < ActiveRecord::Migration
  def self.up
    add_column :measures, :partner_id, :integer
  end

  def self.down
    remove_column :measures, :partner_id
  end
end
