RSpec.describe IML do
  let!(:movie_title) { IML::Text.new 'Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4' }
  let!(:movie) { IML::Text.new(movie_title).detect }
  let!(:tvseries_title) { IML::Text.new 'Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv' }
  let!(:tvseries) { IML::Text.new(tvseries_title).detect }

  it "has a version number" do
    expect(IML::VERSION).not_to be nil
  end

  context 'Base' do
    it '#new initializes a new object' do
      expect(IML::Base.new).to be_an(IML::Base)
    end

    it '#present should produce a non-empty String' do
      expect(movie.present).to be_a(String)
      expect(movie.present).not_to be_empty
    end

    it '#pathname should return pathname' do
      expect(movie.pathname).to be_a(Pathname)
    end

    it '#create_dir should not fail' do
      movie.pretend = true
      expect { movie.create_dir }.not_to raise_error
    end

    it '#move should not fail' do
      movie.pretend = true
      expect { movie.move('somepath') }.not_to raise_error
    end

    it '#move should fail when FileUtils.mv raises Errno::ENOENT' do
      movie.pretend = false
      allow(FileUtils).to receive(:mv).and_raise(Errno::ENOENT)
      expect(movie.move('somepath')).to eq(1)
    end
  end

  context 'Text' do
    it '#new initializes a new object' do
      expect(IML::Text.new).to be_an(IML::Text)
    end
  end

  context 'Movie' do
    it '#movie? returns a positive result' do
      expect(movie.movie?).to be(true)
    end
  end

  context 'TVSeries' do
    it '#tv? returns a positive result' do
      expect(tvseries.tv?).to be(true)
    end

    it '#season_i should return an integer' do
      expect(tvseries.season_i).to be_an(Integer)
    end

    it '#episode_i should return an integer' do
      expect(tvseries.episode_i).to be_an(Integer)
    end
  end

  context 'Patterns' do
    it '#responds_to_missing? returns correclty' do
      expect(IML::Patterns.new.respond_to?(:quality)).to be(true)
    end
  end

  context 'Hash' do
    it '#responds_to_missing? returns correclty' do
      expect(IML::Hash.new.respond_to?(:some_method)).to be(false)
    end
  end
end
