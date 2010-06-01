class AddAllocatedFlagToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :funds_allocated, :boolean
  end

  def self.down
    remove_column :campaigns, :funds_allocated
  end
end
