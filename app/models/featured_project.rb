class FeaturedProject < ActiveRecord::Base
  belongs_to :project

  def self.find_projects(options = {})
    projects = []
    FeaturedProject.find(:all, options).each do |fp|
      projects << fp.project if fp.project
    end
    projects
  end
end
