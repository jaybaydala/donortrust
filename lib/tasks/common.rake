namespace :rails do
  desc "Freeze rails edge - assumes a typical capistrano deployment setup"
  task :deploy_edge do
    ENV['SHARED_PATH']  = '../../shared' unless ENV['SHARED_PATH']
    ENV['RAILS_PATH'] ||= File.join(ENV['SHARED_PATH'], 'rails')
    ENV['REPO_BRANCH'] ||= ''

    checkout_path = File.join(ENV['RAILS_PATH'], 'head')
    export_path   = "#{ENV['RAILS_PATH']}/#{ENV['REVISION']}"
    symlink_path  = 'vendor/rails'
    
    # do we need to checkout the head?
    unless File.exists?(checkout_path)
      puts 'setting up rails HEAD'
      system "git-clone git://github.com/rails/rails.git #{File.expand_path(checkout_path)}"
    end

    # do we need to export the revision?
    unless File.exists?(export_path)
      puts "setting up rails rev #{ENV['REVISION']}"
      system "cp -r #{File.expand_path(checkout_path)} #{File.expand_path(export_path)} && cd #{File.expand_path(export_path)} && git-checkout #{ENV['REVISION']}"
    end
    
    if File.exists?(checkout_path) && File.exists?(export_path)
      puts 'linking rails'
      rm_rf   symlink_path
      mkdir_p symlink_path

      get_framework_for symlink_path do |framework|
        ln_s File.expand_path("#{export_path}/#{framework}/lib"), "#{symlink_path}/#{framework}/lib"
      end
  
      touch "vendor/rails_#{ENV['REVISION']}"
    else
      raise "ABORTING: #{checkout_path} and #{export_path} don't exist."
    end
  end

  def get_framework_for(*paths)
    %w( railties actionpack activerecord actionmailer activesupport activeresource activemodel ).each do |framework|
      paths.each { |path| mkdir_p "#{path}/#{framework}" }
      yield framework
    end
  end
end