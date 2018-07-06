# frozen_string_literal: true

class IML::Base < OpenStruct
  attr_accessor :format_string

  def initialize(hash = nil)
    super
    process
  end

  def process
    titleize
    delete_fields
  end

  def delete_fields
    each_pair do |k, v|
      delete_field(k) unless v
    end
  end

  def titleize
    self.title = IML::Text.new(title).to_title if title.is_a?(String)
    self.episode_title = IML::Text.new(episode_title).to_title if episode_title.is_a?(String)
    self.episode_title = nil if episode_title.to_s.empty?
    self
  end

  def present
    format_string = output_format
    self.class::PLACEHOLDERS.each do |placeholder, attribute|
      format_string = format_string.gsub(placeholder, send(attribute).to_s)
    end
    format_string
  end

  def output_format
    format_string || self.class::DEFAULT_FORMAT
  end

  def pathname(prefix = nil)
    prefix ? Pathname(prefix) + Pathname(present) : Pathname(present)
  end

  def create_dir(options = {})
    FileUtils.mkdir_p dirname(options[:target]) unless options[:pretend]
  end

  def move(path, options = {})
    FileUtils.mv path, pathname(options[:target]) unless options[:pretend]
  end

  delegate :dirname, to: :pathname

  delegate :basename, to: :pathname
end
