# frozen_string_literal: true

require 'open-uri'
require 'yaml'
require 'tqdm'
require 'logger'
require 'fileutils'
require 'pathname'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'
require 'ostruct'
require 'pry' unless ENV['BUNDLER_VERSION'].nil?
require 'iml/version'
require 'iml/base'
require 'iml/patterns'
require 'iml/text'
require 'iml/movie'
require 'iml/tvseries'
require 'iml/hash'

begin
  require 'iml-imdb'
rescue LoadError
  puts "IMDB support disabled, to enable add 'iml-imdb' to Gemfile or install manually"
end

# IML Namespace
module IML
end
