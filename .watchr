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
  system "bundle exec spec #{file}"
  puts
end

def run_features
  puts "Running default features"
  system "bundle exec cucumber --require features"
  puts
end

def run_feature(file, wip=false)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}#{' on @wip profile' if wip == true}"
  system "bundle exec cucumber --require features #{'-p wip' if wip == true} #{file}"
  puts
end

def run_wip_features
  puts "Running all wip features"
  system "bundle exec cucumber --require features --profile wip"
  puts
end

def run_suite
  puts "Running suite"
  run_features
  run_specs
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
  run_feature match[0], true
end
watch("features/.*/.*\.feature") do |match|
  run_feature match[0], true
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
