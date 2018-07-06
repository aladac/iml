# frozen_string_literal: true

# TV Series media file type class
class IML::TVSeries < IML::Base
  # Formatting placeholders for TV Series
  PLACEHOLDERS = {
    '%T' => :title,
    '%E' => :episode,
    '%S' => :season,
    '%f' => :extension,
    '%e' => :episode_i,
    '%s' => :season_i,
    '%t' => :episode_title,
    '%a' => :audio,
    '%v' => :codec,
    '%q' => :quality,
    '%g' => :group,
    '%z' => :source
  }.freeze

  # Default formatting sting
  DEFAULT_FORMAT = '%T/Season %s/%T - S%SE%E.%f'

  def tv?
    true
  end

  def season_i
    season.to_i
  end

  def episode_i
    episode.to_i
  end
end
