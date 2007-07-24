namespace :test do
  namespace :dt do
    Rake::TestTask.new(:units => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/unit/dt/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:dt:units'].comment = "Run the unit tests in test/unit"

    Rake::TestTask.new(:functionals => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/functional/dt/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:dt:functionals'].comment = "Run the functional tests in test/functional"

    Rake::TestTask.new(:integration => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/integration/dt/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:dt:integration'].comment = "Run the integration tests in test/integration"
  end
end

%w(dt:functionals dt:units dt:integration).each do |type|
  namespace :spec do
    desc "Show specs when testing #{type}"
    task type do
      ENV['TESTOPTS'] = '--runner=s'
      Rake::Task["test:#{type}"].invoke
    end
  end
end
