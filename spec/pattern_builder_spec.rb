RSpec.describe IML::PatternBuilder, :verified do
  subject(:builder) { described_class.new(IML.configuration) }

  describe "#movie_patterns" do
    it "returns an array of Regexp" do
      expect(builder.movie_patterns).to all(be_a(Regexp))
    end

    it "returns 2 patterns" do
      expect(builder.movie_patterns.size).to eq(2)
    end

    it "patterns are case-insensitive" do
      builder.movie_patterns.each do |p|
        expect(p.options & Regexp::IGNORECASE).not_to eq(0)
      end
    end

    it "patterns are frozen" do
      expect(builder.movie_patterns).to be_frozen
    end

    it "caches the result" do
      expect(builder.movie_patterns).to equal(builder.movie_patterns)
    end

    it "matches standard movie filename" do
      filename = "Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4"
      match = builder.movie_patterns.lazy.filter_map { |p| filename.match(p) }.first
      expect(match).not_to be_nil
      expect(match[:title]).to eq("Cool.Movie")
      expect(match[:year]).to eq("2018")
    end

    it "matches bracket-format movie filename" do
      filename = "Cool.Movie_(2018)_[720p,BluRay,AAC,H264]_-_GROUP.mp4"
      match = builder.movie_patterns.lazy.filter_map { |p| filename.match(p) }.first
      expect(match).not_to be_nil
      expect(match[:year]).to eq("2018")
    end

    it "does not match TV series filenames" do
      filename = "Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv"
      matches = builder.movie_patterns.filter_map { |p| filename.match(p) }
      expect(matches).to be_empty
    end
  end

  describe "#tv_patterns" do
    it "returns an array of Regexp" do
      expect(builder.tv_patterns).to all(be_a(Regexp))
    end

    it "returns 1 pattern" do
      expect(builder.tv_patterns.size).to eq(1)
    end

    it "matches standard TV filename" do
      filename = "Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv"
      match = builder.tv_patterns.first.match(filename)
      expect(match).not_to be_nil
      expect(match[:title]).to eq("Cool.Tv.Show")
      expect(match[:season]).to eq("03")
      expect(match[:episode]).to eq("09")
    end

    it "matches TV filename with episode title" do
      filename = "Show.Name.S01E05.Episode.Title.720p.HDTV.x264-GROUP.mkv"
      match = builder.tv_patterns.first.match(filename)
      expect(match).not_to be_nil
      expect(match[:episode_title]).not_to be_nil
    end

    it "matches TV filename with quality" do
      filename = "Show.S02E10.1080p.WEBRip.x264-GROUP.mkv"
      match = builder.tv_patterns.first.match(filename)
      expect(match).not_to be_nil
      expect(match[:quality]).to eq("1080p")
    end
  end
end
