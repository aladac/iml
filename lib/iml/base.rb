# frozen_string_literal: true

# Base media file class
class IML::Base < OpenStruct
  # @return <String> Allows retrieving and setting of the format string for the output name
  attr_accessor :format_string
  # @return <String> Allows for setting and getting the output path sans the output base filename
  attr_accessor :prefix
  # @return <Boolean> Allows for setting and getting dry run setting
  attr_accessor :pretend

  delegate :dirname, to: :pathname # @return <Pathname> output path sans the output base filename
  delegate :basename, to: :pathname # @return <Pathname> output base filename

  def initialize(hash = nil, options = {})
    @prefix = options[:target]
    @pretend = options[:pretend]
    super(hash)
    process if hash
  end

  # @return [String] formated output filename
  def present
    format_string = output_format
    self.class::PLACEHOLDERS.each do |placeholder, attribute|
      format_string = format_string.gsub(placeholder, send(attribute).to_s)
    end
    format_string
  end

  # @return [Pathname] full output path of the media file
  def pathname
    @prefix ? Pathname(@prefix) + Pathname(present) : Pathname(present)
  end

  # Creates the output directory if needed
  # @return [Array<String>] array containing the path of the created output directory
  # @example
  #   movie = IML::Text.new('Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4').detect
  #   # => <IML::Movie title="Cool Movie", year="2018", quality="720p", source="BluRay" ..>
  #   movie.create_dir
  #   # => ["."]
  def create_dir
    FileUtils.mkdir_p dirname unless @pretend
  end

  # Moves the media file to the output directory
  # @return <Integer> 0 on success, 1 on failure
  def move(path)
    FileUtils.mv path, pathname unless @pretend
  rescue Errno::ENOENT
    1
  end

  def imdb
    return nil unless imdb_doc
    fetch_director
    fetch_rating
    fetch_writer
    fetch_summary
    fetch_actors
    self
  end

  private

  def imdb_link
    search = IML::IMDB.new(title)
    result = search.result
    return nil if result.empty?
    self.year = result.first.year
    result.first.try(:href)
  end

  def imdb_doc
    link = imdb_link
    return nil unless imdb_link
    @html ||= open("https://www.imdb.com#{link}").read
    @imdb_doc ||= Nokogiri::HTML(@html)
  end

  def fetch_director
    self.director ||= imdb_doc.css('span[itemprop=director]').css('span[itemprop=name]').map { |e| e.child.to_s }.join(', ')
  end

  def fetch_rating
    self.rating ||= imdb_doc.css('span.rating').first.child.to_s
  end

  def fetch_writer
    self.writer ||= imdb_doc.css('span[itemprop=creator]').css('span[itemprop=name]').map { |e| e.child.to_s }.join(', ')
  end

  def fetch_summary
    self.summary ||= imdb_doc.css('div.summary_text').text.strip
  end

  def fetch_actors
    self.actors ||= imdb_doc.css('span[itemprop=actors]').css('span[itemprop=name]').map { |e| e.child.to_s }.join(', ')
  end

  def output_format
    format_string || self.class::DEFAULT_FORMAT
  end

  # Process the IML::Base object and apply some normalizing and cleanup on the fields
  def process
    normalize_video_codec_name if codec
    normalize_audio_codec_name if audio
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
end
