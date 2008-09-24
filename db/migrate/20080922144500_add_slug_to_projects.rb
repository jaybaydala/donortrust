class AddSlugToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :slug, :string, :null => true
    add_index :projects, :slug, :unique => true
    add_column :project_versions, :slug, :string, :null => true
    if %w(production staging development).include?(ENV['RAILS_ENV'])
      say "Updating admin and unallocated project to use `slug' column"
      begin 
        cf_admin_project = Project.find(10)
        cf_admin_project.update_attributes({:slug => 'admin'})
      rescue ActiveRecord::RecordNotFound
      end
      begin 
        cf_unallocated_project = Project.find(11)
        cf_unallocated_project.update_attributes({:slug => 'unallocated'})
      rescue ActiveRecord::RecordNotFound
      end
    end
  end

  def self.down
    remove_column :projects, :slug
    remove_column :project_versions, :slug
  end
end
