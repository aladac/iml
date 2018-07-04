# frozen_string_literal: true

class IML::Text < String
  def to_title
    tr('.', ' ').tr('_', ' ').titleize
  end

  def match_and_return(pattern)
    match = self.match(pattern)
    if match
      IML::Base.new(match.named_captures)
    else
      false
    end
  end

  def detect
    tv? || movie? || false
  end

  def tv?
    match = match_patterns(IML::Patterns.new.tv)
    match ? IML::TVSeries.new(match) : false
  end

  def movie?
    match = match_patterns(IML::Patterns.new.movie)
    match ? IML::Movie.new(match) : false
  end

  def match_patterns(patterns)
    patterns.each do |pattern|
      match = match_and_return(pattern)
      return match if match
    end
    false
  end
end
