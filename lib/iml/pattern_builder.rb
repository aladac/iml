# frozen_string_literal: true

module IML
  class PatternBuilder
    FIELDS = %i[
      title year tags quality source codec audio group
      extension season episode episode_title extras
      video_tags bit_depth
    ].freeze

    def initialize(config)
      @config = config
      @field_patterns = {}
      FIELDS.each { |f| @field_patterns[f] = config.pattern_for(f) }
    end

    def movie_patterns
      @movie_patterns ||= [
        # Standard: title.year.tags.quality.source.codec.audio-group.ext
        build('^%<title>s\.%<year>s\.?%<tags>s\.?%<quality>s?\.?%<source>s\.%<codec>s\.?%<audio>s?-?%<group>s\.%<extension>s$'),
        # Audio before codec: title.year.tags.quality.source.audio.codec-group.ext
        build('^%<title>s\.%<year>s\.?%<tags>s\.?%<quality>s?\.?%<source>s\.%<audio>s\.?%<codec>s-?%<group>s\.%<extension>s$'),
        # Bracket format: title_(year)_[quality,source,audio,codec]_-_group.ext
        build('^%<title>s_\(%<year>s\)_\[%<quality>s,%<source>s,%<audio>s,%<codec>s\]_-_%<group>s.%<extension>s$'),
        # P2P with bracket group: title.year.tags.quality.source.extras[group].ext
        build('^%<title>s\.%<year>s\.?%<tags>s\.?%<quality>s?\.?%<source>s\.%<extras>s%<group>s\.%<extension>s$'),
        # Extended: title.year.quality.video_tags.source.codec.bit_depth.audio-group.ext
        build('^%<title>s\.%<year>s\.?%<tags>s\.?%<quality>s?\.?%<video_tags>s%<source>s\.%<codec>s\.?%<bit_depth>s\.?%<audio>s?-?%<group>s\.%<extension>s$')
      ].freeze
    end

    def tv_patterns
      @tv_patterns ||= [
        build('^%<title>s.S%<season>sE%<episode>s.?%<episode_title>s?.?%<quality>s?.%<source>s.%<audio>s?\.?%<codec>s-%<group>s.%<extension>s$')
      ].freeze
    end

    private

    def build(template)
      Regexp.new(format(template, @field_patterns), Regexp::IGNORECASE)
    end
  end
end
