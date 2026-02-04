# frozen_string_literal: true

class IML::Formatter
  def call(media, format: nil)
    format_string = format || media.class::DEFAULT_FORMAT
    media.class::PLACEHOLDERS.each do |placeholder, attribute|
      format_string = format_string.gsub(placeholder, media.send(attribute).to_s)
    end
    format_string
  end

  def pathname(media, format: nil, target: nil)
    formatted = call(media, format: format)
    target ? Pathname(target) + Pathname(formatted) : Pathname(formatted)
  end
end
