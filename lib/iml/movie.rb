# frozen_string_literal: true

# Movie media file type class
class IML::Movie < IML::Base
  # Formatting placeholders for Movies
  PLACEHOLDERS = {
    '%T' => :title,
    '%Y' => :year,
    '%f' => :extension,
    '%v' => :codec,
    '%a' => :audio,
    '%g' => :group,
    '%z' => :source,
    '%q' => :quality
  }.freeze

  # Default formatting string
  DEFAULT_FORMAT = '%T (%Y).%f'

  # @return <Boolean> always true for IML::Movie objects
  def movie?
    true
  end
end
