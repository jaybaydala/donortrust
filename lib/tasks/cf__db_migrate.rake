namespace :db do
  desc "Revert database schema back to version 0, then up to the current version or version specified. Set RAILS_ENV=development to load data and/or VERSION to the desired version to migrate to."
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

