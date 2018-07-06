# frozen_string_literal: true

class IML::Movie < IML::Base
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

  DEFAULT_FORMAT = '%T (%Y).%f'

  def movie?
    true
  end
end
