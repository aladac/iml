# frozen_string_literal: true

class IML::Base < OpenStruct
  attr_accessor :format_string

  def initialize(hash = nil, options = {})
    @prefix = options[:target]
    @pretend = options[:pretend]
    super(hash)
    process
  end

  def process
    normalize_video_codec_name
    normalize_audio_codec_name
    titleize
    delete_fields
  end

  def normalize_video_codec_name
    self.codec = IML::Patterns::CODEC[codec.downcase] unless IML::Patterns::CODEC.value?(codec.downcase)
  end

  def normalize_audio_codec_name
    return false if final_audio_format?
    self.channels = IML::Patterns::AUDIO[audio.downcase][:channels]
    self.audio = IML::Patterns::AUDIO[audio.downcase][:name]
  end

  def final_audio_format?
    return true if IML::Patterns::AUDIO.values.map { |a| a[:name] }.include?(audio)
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
