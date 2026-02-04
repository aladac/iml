# frozen_string_literal: true

class IML::Media::TvSeries
  ATTRIBUTES = %i[
    title season episode episode_title quality source
    codec audio channels group extension
  ].freeze

  PLACEHOLDERS = {
    "%T" => :title,
    "%E" => :episode,
    "%S" => :season,
    "%f" => :extension,
    "%e" => :episode_i,
    "%s" => :season_i,
    "%t" => :episode_title,
    "%a" => :audio,
    "%v" => :codec,
    "%q" => :quality,
    "%g" => :group,
    "%z" => :source
  }.freeze

  DEFAULT_FORMAT = "%T/Season %s/%T - S%SE%E.%f"

  attr_reader(*ATTRIBUTES)

  def initialize(**attrs)
    ATTRIBUTES.each { |a| instance_variable_set(:"@#{a}", attrs[a]) }
  end

  def movie? = false

  def tv? = true

  def type = :tv

  def season_i
    season.to_i
  end

  def episode_i
    episode.to_i
  end
end
