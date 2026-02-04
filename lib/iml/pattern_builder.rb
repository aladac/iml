# frozen_string_literal: true

class IML::PatternBuilder
  FIELDS = %i[
    title year quality source codec audio group
    extension season episode episode_title
  ].freeze

  def initialize(config)
    @config = config
    @field_patterns = {}
    FIELDS.each { |f| @field_patterns[f] = config.pattern_for(f) }
  end

  def movie_patterns
    @movie_patterns ||= [
      build('^%<title>s\.%<year>s\.?%<quality>s?\.%<source>s\.%<codec>s\.?%<audio>s?-?%<group>s\.%<extension>s$'),
      build('^%<title>s_\(%<year>s\)_\[%<quality>s,%<source>s,%<audio>s,%<codec>s\]_-_%<group>s.%<extension>s$')
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
