require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

desc 'Console'
task :console do
  require 'bundler/setup'
  require 'iml'
  require 'pry'
  Pry.start
end

task default: %i[rubocop spec]
