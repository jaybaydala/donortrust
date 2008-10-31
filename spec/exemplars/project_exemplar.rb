class Project < ActiveRecord::Base
  generator_for :name, :start => 'Project' do |prev|
    prev.succ
  end
  generator_for :target_start_date => Time.now
  generator_for :total_cost => 25000
  generator_for :program do
    Program.generate
  end
  generator_for :place do
    Place.generate
  end
  generator_for :project_status do
    ProjectStatus.generate
  end
  generator_for :partner do
    Partner.generate
  end
end