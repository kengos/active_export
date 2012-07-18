#!/usr/bin/env rake
require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

def cmd(command)
  puts command
  raise unless system command
end

# Import all our rake tasks
FileList['tasks/**/*.rake'].each { |task| import task }

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
# Run the specs
task :default => :spec