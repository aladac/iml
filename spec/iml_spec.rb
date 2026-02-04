RSpec.describe IML do
  let(:movie_filename) { "Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4" }
  let(:tv_filename) { "Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv" }
  let(:movie) { IML.parse(movie_filename) }
  let(:tvseries) { IML.parse(tv_filename) }

  it "has a version number" do
    expect(IML::VERSION).not_to be_nil
  end

  describe ".parse" do
    it "returns a Movie for movie filenames" do
      expect(movie).to be_a(IML::Media::Movie)
    end

    it "returns a TvSeries for TV filenames" do
      expect(tvseries).to be_a(IML::Media::TvSeries)
    end

    it "returns nil for unrecognized filenames" do
      expect(IML.parse("random_file.txt")).to be_nil
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(IML.configuration).to be_a(IML::Configuration)
    end
  end

  context "Movie" do
    it "#movie? returns true" do
      expect(movie.movie?).to be(true)
    end

    it "#tv? returns false" do
      expect(movie.tv?).to be(false)
    end

    it "has normalized attributes" do
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
  end

  context "TvSeries" do
    it "#tv? returns true" do
      expect(tvseries.tv?).to be(true)
    end

    it "#movie? returns false" do
      expect(tvseries.movie?).to be(false)
    end

    it "#season_i returns an integer" do
      expect(tvseries.season_i).to eq(3)
    end

    it "#episode_i returns an integer" do
      expect(tvseries.episode_i).to eq(9)
    end

    it "has normalized attributes" do
      expect(tvseries.title).to eq("Cool Tv Show")
      expect(tvseries.season).to eq("03")
      expect(tvseries.episode).to eq("09")
      expect(tvseries.codec).to eq("h.264")
    end
  end

  context "Formatter" do
    let(:formatter) { IML::Formatter.new }

    it "formats movie with default format" do
      expect(formatter.call(movie)).to eq("Cool Movie (2018).mp4")
    end

    it "formats TV series with default format" do
      expect(formatter.call(tvseries)).to eq("Cool Tv Show/Season 3/Cool Tv Show - S03E09.mkv")
    end

    it "formats with custom format string" do
      expect(formatter.call(movie, format: "%T.%Y.%v.%f")).to eq("Cool Movie.2018.h.264.mp4")
    end

    it "#pathname returns a Pathname" do
      expect(formatter.pathname(movie)).to be_a(Pathname)
    end

    it "#pathname includes target prefix" do
      path = formatter.pathname(movie, target: "/output")
      expect(path.to_s).to eq("/output/Cool Movie (2018).mp4")
    end
  end

  context "FileMover" do
    let(:mover) { IML::FileMover.new }

    it "returns destination in pretend mode" do
      dest = mover.call("somepath", movie, pretend: true)
      expect(dest).to be_a(Pathname)
      expect(dest.to_s).to eq("Cool Movie (2018).mp4")
    end

    it "raises FileNotFoundError for missing source" do
      expect { mover.call("nonexistent", movie) }.to raise_error(IML::FileNotFoundError)
    end
  end

  context "PatternBuilder" do
    let(:builder) { IML::PatternBuilder.new(IML.configuration) }

    it "builds movie patterns" do
      expect(builder.movie_patterns).to all(be_a(Regexp))
      expect(builder.movie_patterns.size).to eq(2)
    end

    it "builds tv patterns" do
      expect(builder.tv_patterns).to all(be_a(Regexp))
      expect(builder.tv_patterns.size).to eq(1)
    end
  end

  context "Normalizer" do
    let(:normalizer) { IML::Normalizer.new(IML.configuration) }

    it "normalizes video codec" do
      result = normalizer.call({"codec" => "x264", "title" => "Test"})
      expect(result[:codec]).to eq("h.264")
    end

    it "normalizes audio codec with channels" do
      result = normalizer.call({"audio" => "aac2.0", "title" => "Test"})
      expect(result[:audio]).to eq("AAC")
      expect(result[:channels]).to eq("2.0")
    end

    it "titleizes title" do
      result = normalizer.call({"title" => "cool.movie"})
      expect(result[:title]).to eq("Cool Movie")
    end
  end
end
