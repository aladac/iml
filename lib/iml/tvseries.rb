# frozen_string_literal: true

class IML::TVSeries < IML::Base
  PLACEHOLDERS = {
    '%T' => :title,
    '%E' => :episode,
    '%S' => :season,
    '%f' => :extension,
    '%e' => :episode_i,
    '%s' => :season_i
  }.freeze

  DEFAULT_FORMAT = '%T/Season %s/%T - S%SE%E.%f'

  def tv?
    true
  end

  def season_i
    season.to_i
  end

  def episode_i
    episdoe.to_i
  end
end
