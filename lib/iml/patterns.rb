# frozen_string_literal: true

class IML::Patterns
  def config
    IML::Hash.new YAML.load_file('patterns.yml')
  end

  def self.config
    new.config
  end

  def method_missing(method_name)
    m = config[method_name]
    super unless m
    if m.is_a?(Hash)
      "(?<#{method_name}>(#{m.keys.join('|')}))"
    elsif m.is_a?(Array)
      "(?<#{method_name}>(#{m.join('|')}))"
    elsif m.is_a?(String)
      "(?<#{method_name}>#{m})"
    end
  end

  def respond_to_missing?(method_name, _include_private = false)
    true if self.class.const_defined?(method_name.to_s.upcase)
  end

  def media_info
    {
      title: title, year: year, quality: quality, source: source, codec: codec, audio: audio, group: group,
      extension: extension, season: season, episode: episode, episode_title: episode_title
    }
  end

  def format_pattern(pattern)
    format(pattern, media_info)
  end

  def movie
    [
      /#{format_pattern('^%<title>s\.%<year>s\.?%<quality>s?\.%<source>s\.%<codec>s\.?%<audio>s?-?%<group>s\.%<extension>s$')}/i,
      /#{format_pattern('^%<title>s_\(%<year>s\)_\[%<quality>s,%<source>s,%<audio>s,%<codec>s\]_-_%<group>s.%<extension>s$')}/i
    ]
  end

  def tv
    [
      /#{format_pattern('^%<title>s.S%<season>sE%<episode>s.?%<episode_title>s?.?%<quality>s?.%<source>s.%<audio>s?\.?%<codec>s-%<group>s.%<extension>s$')}/i
    ]
  end
end
