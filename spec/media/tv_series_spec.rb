RSpec.describe IML::Media::TvSeries, :verified do
  subject(:tv) do
    described_class.new(
      title: "Cool Tv Show",
      season: "03",
      episode: "09",
      episode_title: nil,
      quality: nil,
      source: "WEB",
      codec: "h.264",
      audio: nil,
      group: "GROUP",
      extension: "mkv"
    )
  end

  describe "#initialize" do
    it "sets all attributes" do
      expect(tv.title).to eq("Cool Tv Show")
      expect(tv.season).to eq("03")
      expect(tv.episode).to eq("09")
      expect(tv.source).to eq("WEB")
      expect(tv.codec).to eq("h.264")
      expect(tv.group).to eq("GROUP")
      expect(tv.extension).to eq("mkv")
    end

    it "handles nil optional attributes" do
      expect(tv.episode_title).to be_nil
      expect(tv.quality).to be_nil
      expect(tv.audio).to be_nil
    end

    it "handles missing attributes" do
      minimal = described_class.new(title: "Show", season: "01", episode: "01")
      expect(minimal.codec).to be_nil
    end
  end

  describe "type predicates" do
    it "#tv? returns true" do
      expect(tv.tv?).to be(true)
    end

    it "#movie? returns false" do
      expect(tv.movie?).to be(false)
    end

    it "#type returns :tv" do
      expect(tv.type).to eq(:tv)
    end
  end

  describe "#season_i" do
    it "returns season as integer" do
      expect(tv.season_i).to eq(3)
    end

    it "returns 0 for nil season" do
      no_season = described_class.new(title: "Show")
      expect(no_season.season_i).to eq(0)
    end
  end

  describe "#episode_i" do
    it "returns episode as integer" do
      expect(tv.episode_i).to eq(9)
    end

    it "returns 0 for nil episode" do
      no_episode = described_class.new(title: "Show")
      expect(no_episode.episode_i).to eq(0)
    end
  end

  describe "with episode title" do
    subject(:tv_with_title) do
      described_class.new(
        title: "Show",
        season: "01",
        episode: "05",
        episode_title: "Pilot Episode"
      )
    end

    it "stores episode title" do
      expect(tv_with_title.episode_title).to eq("Pilot Episode")
    end
  end

  describe "constants" do
    it "has ATTRIBUTES including season and episode" do
      expect(described_class::ATTRIBUTES).to include(:season, :episode, :episode_title)
    end

    it "has PLACEHOLDERS for season/episode integers" do
      expect(described_class::PLACEHOLDERS).to include("%e" => :episode_i, "%s" => :season_i)
    end

    it "has DEFAULT_FORMAT with directory structure" do
      expect(described_class::DEFAULT_FORMAT).to include("Season %s")
    end
  end
end
