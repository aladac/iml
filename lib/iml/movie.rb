# frozen_string_literal: true

class IML::Movie < IML::Base
  PLACEHOLDERS = {
    '%T' => :title,
    '%Y' => :year,
    '%e' => :extension
  }.freeze

  DEFAULT_FORMAT = '%T (%Y).%e'

  def movie?
    true
  end
end
