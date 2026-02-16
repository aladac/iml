# frozen_string_literal: true

RSpec.describe IML, :verified do
  describe 'VERSION' do
    it 'is defined' do
      expect(IML::VERSION).not_to be_nil
    end

    it 'follows semver format' do
      expect(IML::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end

  describe '.parse' do
    it 'returns a Movie for movie filenames' do
      result = IML.parse('Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4')
      expect(result).to be_a(IML::Media::Movie)
    end

    it 'returns a TvSeries for TV filenames' do
      result = IML.parse('Cool.Tv.Show.S03E09.WEBRip.x264-GROUP.mkv')
      expect(result).to be_a(IML::Media::TvSeries)
    end

    it 'returns nil for unrecognized filenames' do
      expect(IML.parse('random_file.txt')).to be_nil
    end
  end

  describe '.configuration' do
    it 'returns a Configuration instance' do
      expect(IML.configuration).to be_a(IML::Configuration)
    end

    it 'caches the instance' do
      expect(IML.configuration).to equal(IML.configuration)
    end

    it 'accepts a custom path' do
      path = File.expand_path('../patterns.yml', __dir__)
      config = IML.configuration(path)
      expect(config).to be_a(IML::Configuration)
    end
  end

  describe '.reset_configuration!' do
    it 'clears cached configuration' do
      first = IML.configuration
      IML.reset_configuration!
      second = IML.configuration
      expect(first).not_to equal(second)
    end
  end

  describe 'error classes' do
    it 'defines IML::Error' do
      expect(IML::Error).to be < StandardError
    end

    it 'defines IML::FileNotFoundError' do
      expect(IML::FileNotFoundError).to be < IML::Error
    end
  end
end
