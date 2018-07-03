require 'iml/version'
require 'active_support/inflector'
require 'ostruct'
require 'pry'

module IML
  class Base < OpenStruct
    def titleize
      self.title = title.to_title if title.is_a?(String)
      self.episode_title = episode_title.to_title if episode_title.is_a?(String)
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

class IML::String < String
  def to_title
    tr('.', ' ').tr('_', ' ').titleize
  end

  def match_and_return(pattern)
    match = self.match(pattern)
    if match
      IML::Base.new(match.named_captures).titleize
    else
      false
    end
  end

  def detect
    tv? || movie? || false
  end

  def tv?
    match = match_and_return(/^(?<title>.*).S(?<season>\d*)E(?<episode>\d*)\.(?<episode_title>.*?)\.?(?<quality>\d*p)\.?(?<source>.*)\.(?<codec>.*)-(?<group>.*)\.(?<extension>.*)$/i)
    match ? IML::TVSeries.new(match) : false
  end

  def movie?
    match = match_and_return(/(?<title>.*?)\.(?<year>\d{4}).(?<quality>\d*p)?.(?<source>.*)\.(?<codec>.*)\.(?<audio>.*)-(?<group>.*)\.(?<extension>.*)/)
    match ? IML::Movie.new(match) : false
  end
end
