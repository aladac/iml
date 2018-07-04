# frozen_string_literal: true

class IML::Patterns
  QUALITY = %w[720p 1080p].freeze
  CODEC = %w[x264 x265 h264 h265 xvid].freeze
  SOURCE = %w[hdtv bdrip dvdrip webrip bluray].freeze
  AUDIO = %w[aac flac ac3 dts DTS-HD.MA.5.1 TrueHD.7.1.Atmos].freeze
  SEASON = '\\d{2}'
  EPISODE = '\\d{2}'
  EPISODE_TITLE = '.*?'
  EXTENSION = %w[avi mp4 mkv].freeze
  GROUP = '.*'
  TITLE = '.*'
  YEAR = '\\d{4}'

  def method_missing(method)
    const = self.class.const_get(method.to_s.upcase)
    super unless const
    if const.is_a?(Array)
      "(?<#{method}>(#{const.join('|')}))"
    elsif const.is_a?(String)
      "(?<#{method}>#{const})"
    end
  end

  def respond_to_missing?(method)
    true if self.class.const_defined(method.to_s.upcase)
  end

  def pattern(type)
    const = self.class.const_get(type.to_s.upcase)
    if const.is_a?(Array)
      "(?<#{type}>(#{const.join('|')}))"
    elsif const.is_a?(String)
      "(?<#{type}>#{const})"
    end
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
      /#{format_pattern('^%<title>s.%<year>s.?%<quality>s?.%<source>s.%<codec>s.?%<audio>s?-?%<group>s.%<extension>s$')}/i,
      /#{format_pattern('^%<title>s_\(%<year>s\)_\[%<quality>s,%<source>s,%<audio>s,%<codec>s\]_-_%<group>s.%<extension>s$')}/i
    ]
  end

  def tv
    [
      /#{format_pattern('^%<title>s.S%<season>sE%<episode>s.?%<episode_title>s?.?%<quality>s?.%<source>s.%<codec>s-%<group>s.%<extension>s$')}/i
    ]
  end
end
