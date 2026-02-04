# frozen_string_literal: true

class IML::Configuration
  attr_reader :data

  def initialize(path = nil)
    path ||= default_path
    @data = YAML.safe_load_file(path, permitted_classes: [Symbol])
  end

  def codec_map
    @codec_map ||= data.fetch("codec", {})
  end

  def audio_map
    @audio_map ||= data.fetch("audio", {})
  end

  def source_map
    @source_map ||= data.fetch("source", {})
  end

  def quality_list
    @quality_list ||= data.fetch("quality", [])
  end

  def extension_list
    @extension_list ||= data.fetch("extension", [])
  end

  def pattern_for(field)
    value = data.fetch(field.to_s)

    case value
    when Hash
      "(?<#{field}>(#{value.keys.join("|")}))"
    when Array
      "(?<#{field}>(#{value.join("|")}))"
    when String
      "(?<#{field}>#{value})"
    end
  end

  private

  def default_path
    File.expand_path("../../patterns.yml", __dir__)
  end
end
