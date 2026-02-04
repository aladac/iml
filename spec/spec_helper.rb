require "simplecov"
SimpleCov.start do
  minimum_coverage 95
  add_filter "/spec/"
end

require "bundler/setup"
require "iml"
require "tmpdir"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed

  config.before { IML.reset_configuration! }
end
