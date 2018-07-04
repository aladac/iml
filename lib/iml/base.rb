# frozen_string_literal: true

module IML
  class Base < OpenStruct
    def initialize(hash = nil)
      super
      process
    end

    def process
      titleize
      delete_fields
    end

    def delete_fields
      each_pair do |k, v|
        delete_field(k) unless v
      end
    end

    def titleize
      self.title = Text.new(title).to_title if title.is_a?(String)
      self.episode_title = Text.new(episode_title).to_title if episode_title.is_a?(String)
      self.episode_title = nil if episode_title.to_s.empty?
      self
    end
  end

  class Movie < Base
    def movie?
      true
    end
  end

  class TVSeries < Base
    def tv?
      true
    end
  end
end
