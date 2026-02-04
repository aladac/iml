# frozen_string_literal: true

require "open-uri"
require "yaml"
require "logger"
require "fileutils"
require "active_support/inflector"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/hash"
require "ostruct"
require "iml/version"
require "iml/base"
require "iml/patterns"
require "iml/text"
require "iml/movie"
require "iml/tvseries"
require "iml/hash"

begin
  require "iml-imdb"
rescue LoadError
  # IMDB support disabled
end

# IML Namespace
module IML
end
