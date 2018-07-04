# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Console'
task :console do
  require 'bundler/setup'
  require 'iml'
  require 'pry'
  Pry.start
end

task default: :spec
