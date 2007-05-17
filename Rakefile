require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

namespace :db do
  desc "Revert database schema back to version 0, then up to the current version or version specified." 
  task :reload => :environment do
    
    print "Reverting to VERSION=0\n"
    old_version = ENV['VERSION']
    ENV['VERSION'] = '0'
    Rake::Task["db:migrate"].execute      
    
    if (old_version)
      ENV['VERSION'] = old_version
      print "Migrating to version #{old_version}\n" 
    else
      ENV.delete('VERSION')
      print "Migrating to newest version\n"      
    end
    Rake::Task["db:migrate"].execute                    
    print "Done migration\n"
    
    #Rake::Task["db:fixtures:load"].invoke
  end
end
