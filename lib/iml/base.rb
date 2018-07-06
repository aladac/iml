# frozen_string_literal: true

class IML::Base < OpenStruct
  attr_accessor :format_string
  attr_accessor :prefix
  attr_accessor :pretend

  def initialize(hash = nil, options = {})
    @prefix = options[:target]
    @pretend = options[:pretend]
    super(hash)
    process if hash
  end

  def process
    normalize_video_codec_name
    normalize_audio_codec_name
    titleize
    delete_fields
  end

  def normalize_video_codec_name
    self.codec = IML::Patterns.config.codec[codec.downcase] unless IML::Patterns.config.codec.value?(codec.downcase)
  end

  def normalize_audio_codec_name
    return false if final_audio_format?
    self.channels = IML::Patterns.config.audio[audio.downcase][:channels]
    self.audio = IML::Patterns.config.audio[audio.downcase][:name]
  end

  def final_audio_format?
    return true if IML::Patterns.config.audio.values.map { |a| a[:name] }.include?(audio) || !audio
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

  def pathname
    @prefix ? Pathname(@prefix) + Pathname(present) : Pathname(present)
  end

  def create_dir
    FileUtils.mkdir_p dirname unless @pretend
  end

  def move(path)
    FileUtils.mv path, pathname unless @pretend
  end

  delegate :dirname, to: :pathname

  delegate :basename, to: :pathname
end
