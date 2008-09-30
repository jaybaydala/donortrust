class ProjectStatus < ActiveRecord::Base
  generator_for :name, :start => 'Project Status' do |prev|
    prev.succ
  end
  generator_for :description => "Project Status description"
end