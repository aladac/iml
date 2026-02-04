RSpec.describe IML::Configuration, :verified do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "loads default patterns.yml" do
      expect(config.data).to be_a(Hash)
      expect(config.data).to have_key("codec")
    end

    it "accepts a custom path" do
      custom = described_class.new(File.expand_path("../patterns.yml", __dir__))
      expect(custom.data).to be_a(Hash)
    end

    it "raises on missing file" do
      expect { described_class.new("/nonexistent.yml") }.to raise_error(Errno::ENOENT)
    end
  end

  describe "#codec_map" do
    it "returns codec mappings" do
      expect(config.codec_map).to include("x264" => "h.264", "x265" => "h.265")
    end

    it "caches the result" do
      expect(config.codec_map).to equal(config.codec_map)
    end
  end

  describe "#audio_map" do
    it "returns audio mappings" do
      expect(config.audio_map).to have_key("aac")
      expect(config.audio_map["aac"]).to include("name" => "AAC")
    end

    it "includes entries with channels" do
      entry = config.audio_map["dts-hd.ma.5.1"]
      expect(entry["name"]).to eq("DTS-HD Master")
      expect(entry["channels"]).to eq("5.1")
    end
  end

  describe "#source_map" do
    it "returns source mappings" do
      expect(config.source_map).to include("bluray" => "BD", "hdtv" => "HDTV")
    end
  end

  describe "#quality_list" do
    it "returns quality values" do
      expect(config.quality_list).to include("720p", "1080p", "2160p")
    end
  end

  describe "#extension_list" do
    it "returns supported extensions" do
      expect(config.extension_list).to include("avi", "mp4", "mkv")
    end
  end

  describe "#pattern_for" do
    it "builds named group from Hash keys" do
      pattern = config.pattern_for(:codec)
      expect(pattern).to match(/\(\?<codec>/)
      expect(pattern).to include("x264")
    end

    it "builds named group from Array values" do
      pattern = config.pattern_for(:quality)
      expect(pattern).to match(/\(\?<quality>/)
      expect(pattern).to include("720p")
    end

    it "builds named group from String" do
      pattern = config.pattern_for(:year)
      expect(pattern).to eq('(?<year>\d{4})')
    end

    it "raises KeyError for unknown field" do
      expect { config.pattern_for(:nonexistent) }.to raise_error(KeyError)
    end
  end
end
