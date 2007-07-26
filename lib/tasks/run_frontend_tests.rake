namespace :test do
  namespace :dt do
    Rake::TestTask.new(:units => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/unit/dt/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:dt:units'].comment = "Run the unit tests in test/dt/unit"

    Rake::TestTask.new(:functionals => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/functional/dt/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:dt:functionals'].comment = "Run the functional tests in test/dt/functional"

    Rake::TestTask.new(:integration => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/integration/dt/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:dt:integration'].comment = "Run the integration tests in test/dt/integration"
  end
end

namespace :test do
  desc 'Test all units and functionals in dt/ subdirectories'
  task :dt do
    exceptions = %w(test:dt:units test:dt:functionals test:dt:integration).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        e
      end
    end.compact
  
    exceptions.each {|e| puts e;puts e.backtrace }
    raise "Test failures" unless exceptions.empty?
  end
end

%w(dt dt:functionals dt:units dt:integration).each do |type|
  namespace :spec do
    desc "Show specs when testing #{type}"
    task type do
      ENV['TESTOPTS'] = '--runner=s'
      Rake::Task["test:#{type}"].invoke
    end
  end
end
