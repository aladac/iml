# frozen_string_literal: true

require "yaml"
require "fileutils"
require "iml/version"

module IML
  class Error < StandardError; end
  class FileNotFoundError < Error; end

  module Media; end

  class << self
    def configuration(path = nil)
      if path
        @configuration = Configuration.new(path)
      else
        @configuration ||= Configuration.new
      end
    end

    def reset_configuration!
      @configuration = nil
    end

    def parse(filename)
      Parser.new.parse(filename)
    end
  end
end

require "iml/configuration"
require "iml/pattern_builder"
require "iml/normalizer"
require "iml/formatter"
require "iml/file_mover"
require "iml/parser"
require "iml/media/movie"
require "iml/media/tv_series"
