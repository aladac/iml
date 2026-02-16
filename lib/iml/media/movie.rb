# frozen_string_literal: true

module IML
  module Media
    class Movie
      ATTRIBUTES = %i[title year quality source codec audio channels group extension].freeze

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

      attr_reader(*ATTRIBUTES)

      def initialize(**attrs)
        ATTRIBUTES.each { |a| instance_variable_set(:"@#{a}", attrs[a]) }
      end

      def movie? = true

      def tv? = false

      def type = :movie
    end
  end
end
