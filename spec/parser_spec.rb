RSpec.describe IML::Parser, :verified do
  subject(:parser) { described_class.new }

  describe "#parse" do
    context "with movie filenames" do
      it "detects standard format" do
        result = parser.parse("Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4")
        expect(result).to be_a(IML::Media::Movie)
      end

      it "detects bracket format" do
        result = parser.parse("Cool.Movie_(2018)_[720p,BluRay,AAC,H264]_-_GROUP.mp4")
        expect(result).to be_a(IML::Media::Movie)
      end

      it "extracts all fields" do
        result = parser.parse("Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4")
        expect(result.title).to eq("Cool Movie")
        expect(result.year).to eq("2018")
        expect(result.quality).to eq("720p")
        expect(result.codec).to eq("h.264")
        expect(result.audio).to eq("AAC")
        expect(result.channels).to eq("2.0")
        expect(result.group).to eq("GROUP")
        expect(result.extension).to eq("mp4")
      end

      it "handles 1080p quality" do
        result = parser.parse("Movie.Title.2020.1080p.WEBRip.x265-GROUP.mkv")
        expect(result).to be_a(IML::Media::Movie)
        expect(result.quality).to eq("1080p")
        expect(result.codec).to eq("h.265")
      end

      it "handles missing quality" do
        result = parser.parse("Movie.Title.2020.BluRay.H264.AAC-GROUP.mp4")
        expect(result).to be_a(IML::Media::Movie)
        expect(result.quality).to be_nil
      end

      it "handles missing audio" do
        result = parser.parse("Movie.Title.2020.720p.BluRay.H264-GROUP.mp4")
        expect(result).to be_a(IML::Media::Movie)
      end

      it "normalizes source names" do
        result = parser.parse("Movie.Title.2020.720p.BluRay.H264.AAC-GROUP.mp4")
        expect(result.source).to eq("BD")
      end

      it "normalizes HDTV source" do
        result = parser.parse("Movie.Title.2020.720p.HDTV.H264.AAC-GROUP.mp4")
        expect(result.source).to eq("HDTV")
      end
    end

    context "with TV series filenames" do
      it "detects standard format" do
        result = parser.parse("Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv")
        expect(result).to be_a(IML::Media::TvSeries)
      end

      it "extracts season and episode" do
        result = parser.parse("Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv")
        expect(result.season).to eq("03")
        expect(result.episode).to eq("09")
        expect(result.season_i).to eq(3)
        expect(result.episode_i).to eq(9)
      end

      it "extracts episode title" do
        result = parser.parse("Show.Name.S01E05.Episode.Title.720p.HDTV.x264-GROUP.mkv")
        expect(result).to be_a(IML::Media::TvSeries)
        expect(result.episode_title).not_to be_nil
      end

      it "handles missing quality in TV" do
        result = parser.parse("Show.S01E01.WEBRip.x264-GROUP.mkv")
        expect(result).to be_a(IML::Media::TvSeries)
      end

      it "normalizes TV codec" do
        result = parser.parse("Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv")
        expect(result.codec).to eq("h.264")
      end

      it "titleizes TV show name" do
        result = parser.parse("Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv")
        expect(result.title).to eq("Cool Tv Show")
      end
    end

    context "with unrecognized filenames" do
      it "returns nil for plain text file" do
        expect(parser.parse("readme.txt")).to be_nil
      end

      it "returns nil for empty string" do
        expect(parser.parse("")).to be_nil
      end

      it "returns nil for partial match" do
        expect(parser.parse("Some.Movie.2020.mp4")).to be_nil
      end
    end

    context "TV priority over movie" do
      it "prefers TV match when filename has season/episode" do
        result = parser.parse("Show.S01E01.720p.HDTV.x264-GROUP.mkv")
        expect(result).to be_a(IML::Media::TvSeries)
      end
    end

    context "dependency injection" do
      it "accepts custom config" do
        config = IML::Configuration.new
        custom_parser = described_class.new(config: config)
        result = custom_parser.parse("Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4")
        expect(result).to be_a(IML::Media::Movie)
      end
    end
  end
end
