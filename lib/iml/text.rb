# frozen_string_literal: true

# Parsing and mangling of text metadata
class IML::Text < String
  attr_accessor :options

  def initialize(string = nil, options = {})
    @options = options
    super(string.to_s)
  end

  # Convert IML::Text to desired title format
  def to_title
    tr('.', ' ').tr('_', ' ').titleize
  end

  # Determine if IML::Text matches rules for a media type
  # @return [<IML::Movie>, <IML::TVSeries>] Media type object
  def detect
    tv? || movie? || false
  end

  private

  def tv?
    match = match_patterns(IML::Patterns.new.tv)
    match ? IML::TVSeries.new(match, options) : false
  end

  def movie?
    match = match_patterns(IML::Patterns.new.movie)
    match ? IML::Movie.new(match, options) : false
  end

  def match_patterns(patterns)
    patterns.each do |pattern|
      match = match_and_return(pattern)
      return match if match
    end
    false
  end

  def match_and_return(pattern)
    match = self.match(pattern)
    if match
      match.named_captures
    else
      false
    end
  end
end
