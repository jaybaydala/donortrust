desc "Show specs when testing"
task :spec do
  ENV['TESTOPTS'] = '--runner=s'
  Rake::Task[:test].invoke
end

%w(functionals units integration).each do |type|
  namespace :spec do
    desc "Show specs when testing #{type}"
    task type do
      ENV['TESTOPTS'] = '--runner=s'
      Rake::Task["test:#{type}"].invoke
    end
  end
end

namespace :spec do
  desc "Converts a YAML file into a test/spec skeleton"
  task :yaml_to_spec do
    require 'yaml'

    puts YAML.load_file(ENV['FILE']||!puts("Pass in FILE argument.")&&exit).inject(''){|t,(c,s)|
      t+(s ?%.context "#{c}" do.+s.map{|d|%.\n  xspecify "#{d}" do\n  end\n.}*''+"end\n\n":'')
    }.strip
  end
end