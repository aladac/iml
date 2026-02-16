# frozen_string_literal: true

RSpec.describe IML::Formatter, :verified do
  subject(:formatter) { described_class.new }

  let(:movie) do
    IML::Media::Movie.new(
      title: 'Cool Movie', year: '2018', quality: '720p',
      source: 'BD', codec: 'h.264', audio: 'AAC',
      channels: '2.0', group: 'GROUP', extension: 'mp4'
    )
  end

  let(:tv) do
    IML::Media::TvSeries.new(
      title: 'Cool Tv Show', season: '03', episode: '09',
      codec: 'h.264', source: 'WEB', group: 'GROUP', extension: 'mkv'
    )
  end

  describe '#call' do
    context 'with movie' do
      it 'formats with default format' do
        expect(formatter.call(movie)).to eq('Cool Movie (2018).mp4')
      end

      it 'formats with custom format' do
        expect(formatter.call(movie, format: '%T.%Y.%v.%f')).to eq('Cool Movie.2018.h.264.mp4')
      end

      it 'replaces all placeholders' do
        result = formatter.call(movie, format: '%T-%Y-%q-%z-%v-%a-%g.%f')
        expect(result).to eq('Cool Movie-2018-720p-BD-h.264-AAC-GROUP.mp4')
      end

      it 'handles nil attributes as empty string' do
        minimal = IML::Media::Movie.new(title: 'Test', year: '2020', extension: 'mp4')
        result = formatter.call(minimal, format: '%T.%Y.%q.%f')
        expect(result).to eq('Test.2020..mp4')
      end
    end

    context 'with TV series' do
      it 'formats with default format' do
        expect(formatter.call(tv)).to eq('Cool Tv Show/Season 3/Cool Tv Show - S03E09.mkv')
      end

      it 'formats with season and episode integers' do
        result = formatter.call(tv, format: '%T S%sE%e.%f')
        expect(result).to eq('Cool Tv Show S3E9.mkv')
      end

      it 'formats with episode title placeholder' do
        tv_with_title = IML::Media::TvSeries.new(
          title: 'Show', season: '01', episode: '05',
          episode_title: 'Pilot', extension: 'mkv'
        )
        result = formatter.call(tv_with_title, format: '%T - S%SE%E - %t.%f')
        expect(result).to eq('Show - S01E05 - Pilot.mkv')
      end
    end
  end

  describe '#pathname' do
    it 'returns a Pathname for movie' do
      expect(formatter.pathname(movie)).to be_a(Pathname)
    end

    it 'returns default formatted path' do
      expect(formatter.pathname(movie).to_s).to eq('Cool Movie (2018).mp4')
    end

    it 'prepends target directory' do
      path = formatter.pathname(movie, target: '/output')
      expect(path.to_s).to eq('/output/Cool Movie (2018).mp4')
    end

    it 'uses custom format with target' do
      path = formatter.pathname(movie, format: '%T/%T.%f', target: '/media')
      expect(path.to_s).to eq('/media/Cool Movie/Cool Movie.mp4')
    end

    it 'returns Pathname for TV with subdirectories' do
      path = formatter.pathname(tv)
      expect(path.to_s).to include('Season 3')
    end

    it 'works without target' do
      path = formatter.pathname(movie)
      expect(path).to eq(Pathname('Cool Movie (2018).mp4'))
    end
  end
end
