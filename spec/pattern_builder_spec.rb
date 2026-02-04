RSpec.describe IML::PatternBuilder, :verified do
  subject(:builder) { described_class.new(IML.configuration) }

  describe "#movie_patterns" do
    it "returns an array of Regexp" do
      expect(builder.movie_patterns).to all(be_a(Regexp))
    end

    it "returns 5 patterns" do
      expect(builder.movie_patterns.size).to eq(5)
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

    it "matches audio-before-codec ordering" do
      filename = "The.Plague.2025.REPACK.2160p.AMZN.WEB-DL.DDP5.1.H.265-BYNDR.mkv"
      match = builder.movie_patterns.lazy.filter_map { |p| filename.match(p) }.first
      expect(match).not_to be_nil
      expect(match[:title]).to eq("The.Plague")
      expect(match[:source]).to eq("AMZN.WEB-DL")
      expect(match[:audio]).to eq("DDP5.1")
      expect(match[:codec]).to eq("H.265")
    end

    it "matches filename with REPACK tag" do
      filename = "Movie.2025.REPACK.720p.BluRay.x264.AAC-GROUP.mkv"
      match = builder.movie_patterns.lazy.filter_map { |p| filename.match(p) }.first
      expect(match).not_to be_nil
      expect(match[:tags]).to eq("REPACK")
    end

    it "matches filename with video_tags and bit_depth" do
      filename = "En.Tongs.Au.Pied.De.LHimalaya.2024.2160p.4K.WEB.x265.10bit.AAC5.1-WORLD.mkv"
      match = builder.movie_patterns.lazy.filter_map { |p| filename.match(p) }.first
      expect(match).not_to be_nil
      expect(match[:title]).to eq("En.Tongs.Au.Pied.De.LHimalaya")
      expect(match[:quality]).to eq("2160p")
      expect(match[:source]).to eq("WEB")
      expect(match[:codec]).to eq("x265")
      expect(match[:audio]).to eq("AAC5.1")
    end

    it "matches P2P filename with bracket group" do
      filename = "Anaconda.2025.2160p.iT.WEB-DL.DV.HDR10+.MULTi[Ben The Men].mp4"
      match = builder.movie_patterns.lazy.filter_map { |p| filename.match(p) }.first
      expect(match).not_to be_nil
      expect(match[:title]).to eq("Anaconda")
      expect(match[:source]).to eq("iT.WEB-DL")
      expect(match[:extras]).to eq("DV.HDR10+.MULTi")
      expect(match[:group]).to eq("[Ben The Men]")
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
