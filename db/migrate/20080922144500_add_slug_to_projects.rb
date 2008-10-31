class AddSlugToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :slug, :string, :null => true
    add_index :projects, :slug, :unique => true
    add_column :project_versions, :slug, :string, :null => true
    if %w(production staging development).include?(ENV['RAILS_ENV'])
      say "Updating admin and unallocated project to use `slug' column"
      Project.reset_column_information
      begin 
        admin_project = Project.find(10)
      rescue ActiveRecord::RecordNotFound
        say "couldn't find admin project!!"
      else
        admin_project.update_attributes(:slug => 'admin')
        say "admin project updated" 
      end
      begin 
        unallocated_project = Project.find(11)
      rescue ActiveRecord::RecordNotFound
        say "couldn't find unallocated project!!"
      else
        unallocated_project.update_attributes(:slug => 'unallocated')
        say "unallocated project updated"
      end
    end
  end

  def self.down
    remove_column :projects, :slug
    remove_column :project_versions, :slug
  end
end
