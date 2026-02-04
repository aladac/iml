RSpec.describe IML::Media::Movie, :verified do
  subject(:movie) do
    described_class.new(
      title: "Cool Movie",
      year: "2018",
      quality: "720p",
      source: "BD",
      codec: "h.264",
      audio: "AAC",
      channels: "2.0",
      group: "GROUP",
      extension: "mp4"
    )
  end

  describe "#initialize" do
    it "sets all attributes" do
      expect(movie.title).to eq("Cool Movie")
      expect(movie.year).to eq("2018")
      expect(movie.quality).to eq("720p")
      expect(movie.source).to eq("BD")
      expect(movie.codec).to eq("h.264")
      expect(movie.audio).to eq("AAC")
      expect(movie.channels).to eq("2.0")
      expect(movie.group).to eq("GROUP")
      expect(movie.extension).to eq("mp4")
    end

    it "handles missing attributes as nil" do
      minimal = described_class.new(title: "Test", year: "2020")
      expect(minimal.quality).to be_nil
      expect(minimal.codec).to be_nil
    end

    it "accepts no arguments" do
      empty = described_class.new
      expect(empty.title).to be_nil
    end
  end

  describe "type predicates" do
    it "#movie? returns true" do
      expect(movie.movie?).to be(true)
    end

    it "#tv? returns false" do
      expect(movie.tv?).to be(false)
    end

    it "#type returns :movie" do
      expect(movie.type).to eq(:movie)
    end
  end

  describe "constants" do
    it "has ATTRIBUTES" do
      expect(described_class::ATTRIBUTES).to include(:title, :year, :codec, :audio)
    end

    it "has PLACEHOLDERS" do
      expect(described_class::PLACEHOLDERS).to include("%T" => :title, "%Y" => :year)
    end

    it "has DEFAULT_FORMAT" do
      expect(described_class::DEFAULT_FORMAT).to eq("%T (%Y).%f")
    end

    it "PLACEHOLDERS are frozen" do
      expect(described_class::PLACEHOLDERS).to be_frozen
    end

    it "ATTRIBUTES are frozen" do
      expect(described_class::ATTRIBUTES).to be_frozen
    end
  end
end
