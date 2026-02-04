# frozen_string_literal: true

class IML::Normalizer
  def initialize(config)
    @config = config
  end

  def call(attrs)
    attrs = attrs.transform_keys(&:to_sym)
    attrs = normalize_video_codec(attrs)
    attrs = normalize_audio_codec(attrs)
    attrs = normalize_source(attrs)
    attrs = normalize_titles(attrs)
    remove_blank_values(attrs)
  end

  private

  def normalize_video_codec(attrs)
    codec = attrs[:codec]
    return attrs unless codec

    codec_down = codec.downcase
    normalized = @config.codec_map[codec_down]
    attrs.merge(codec: normalized || codec)
  end

  def normalize_audio_codec(attrs)
    audio = attrs[:audio]
    return attrs unless audio

    audio_down = audio.downcase
    audio_entry = @config.audio_map[audio_down]
    return attrs unless audio_entry.is_a?(Hash)

    final_names = @config.audio_map.values
      .select { |v| v.is_a?(Hash) }
      .map { |v| v["name"] }

    return attrs if final_names.include?(audio)

    attrs.merge(
      audio: audio_entry["name"],
      channels: audio_entry["channels"]
    )
  end

  def normalize_source(attrs)
    source = attrs[:source]
    return attrs unless source

    normalized = @config.source_map[source.downcase]
    attrs.merge(source: normalized || source)
  end

  def normalize_titles(attrs)
    attrs = titleize_field(attrs, :title)
    attrs = titleize_field(attrs, :episode_title)
    if attrs[:episode_title].to_s.strip.empty?
      attrs = attrs.merge(episode_title: nil)
    end
    attrs
  end

  def titleize_field(attrs, field)
    value = attrs[field]
    return attrs unless value.is_a?(String) && !value.empty?

    attrs.merge(field => to_title(value))
  end

  def to_title(str)
    str.tr(".", " ").tr("_", " ").gsub(/\b\w/, &:upcase)
  end

  def remove_blank_values(attrs)
    attrs.reject { |_, v| v.nil? || (v.is_a?(String) && v.empty?) }
  end
end
