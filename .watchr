def run_specs
  puts "Running specs"
  system "bundle exec spec"
  puts
end

def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}"
  system "bundle exec rspec #{file}"
  puts
end

def run_features
  puts "Running default features"
  system "bundle exec cucumber --require features"
  puts
end

def run_feature(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}"
  system "bundle exec cucumber --require features #{file}"
  puts
end

def run_wip_features
  puts "Running wip features"
  system "bundle exec cucumber --require features --profile wip"
  puts
end

def run_suite
  puts "Running suite"
  run_feature
  run_spec
end

watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

watch("app/(.*/.*)\.rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end

watch("features/step_definitions/*_steps\.rb") do |match|
  run_wip_features
end

watch("features/.*\.feature") do |match|
  run_feature match[0]
end
watch("features/.*/.*\.feature") do |match|
  run_feature match[0]
end

# Ctrl-\
Signal.trap 'QUIT' do
  run_wip_features
end

# Ctrl-C
@interrupted = false
Signal.trap 'INT' do
  if @interrupted then
    @wants_to_quit = true
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    @interrupted = false
    run_suite
  end
end
