# frozen_string_literal: true

module IML
  class Parser
    def initialize(config: IML.configuration, pattern_builder: nil, normalizer: nil)
      @config = config
      @pattern_builder = pattern_builder || IML::PatternBuilder.new(config)
      @normalizer = normalizer || IML::Normalizer.new(config)
    end

    def parse(filename)
      try_tv(filename) || try_movie(filename)
    end

    private

    def try_tv(filename)
      captures = match_first(filename, @pattern_builder.tv_patterns)
      return unless captures

      attrs = @normalizer.call(captures)
      IML::Media::TvSeries.new(**attrs)
    end

    def try_movie(filename)
      captures = match_first(filename, @pattern_builder.movie_patterns)
      return unless captures

      attrs = @normalizer.call(captures)
      IML::Media::Movie.new(**attrs)
    end

    def match_first(filename, patterns)
      patterns.each do |pattern|
        match = filename.match(pattern)
        return match.named_captures if match
      end
      nil
    end
  end
end
