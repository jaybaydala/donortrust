class AddFlagForSubagreementsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :is_subagreement_signed, :boolean
    add_column :project_versions, :is_subagreement_signed, :boolean
  end

  def self.down
    remove_column :projects, :is_subagreement_signed
    remove_column :project_versions, :is_subagreement_signed
  end
end
