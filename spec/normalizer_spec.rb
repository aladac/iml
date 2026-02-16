# frozen_string_literal: true

RSpec.describe IML::Normalizer, :verified do
  subject(:normalizer) { described_class.new(IML.configuration) }

  describe '#call' do
    it 'transforms string keys to symbols' do
      result = normalizer.call({ 'title' => 'Test' })
      expect(result).to have_key(:title)
      expect(result).not_to have_key('title')
    end

    it 'removes nil values' do
      result = normalizer.call({ 'title' => 'Test', 'quality' => nil })
      expect(result).not_to have_key(:quality)
    end

    it 'removes empty string values' do
      result = normalizer.call({ 'title' => 'Test', 'quality' => '' })
      expect(result).not_to have_key(:quality)
    end
  end

  describe 'video codec normalization' do
    it 'normalizes x264 to h.264' do
      result = normalizer.call({ 'codec' => 'x264', 'title' => 'T' })
      expect(result[:codec]).to eq('h.264')
    end

    it 'normalizes H264 to h.264' do
      result = normalizer.call({ 'codec' => 'H264', 'title' => 'T' })
      expect(result[:codec]).to eq('h.264')
    end

    it 'normalizes x265 to h.265' do
      result = normalizer.call({ 'codec' => 'x265', 'title' => 'T' })
      expect(result[:codec]).to eq('h.265')
    end

    it 'normalizes avc to h.264' do
      result = normalizer.call({ 'codec' => 'avc', 'title' => 'T' })
      expect(result[:codec]).to eq('h.264')
    end

    it 'normalizes xvid to Xvid' do
      result = normalizer.call({ 'codec' => 'xvid', 'title' => 'T' })
      expect(result[:codec]).to eq('Xvid')
    end

    it 'preserves unknown codec as-is' do
      result = normalizer.call({ 'codec' => 'vp9', 'title' => 'T' })
      expect(result[:codec]).to eq('vp9')
    end

    it 'skips normalization when codec is nil' do
      result = normalizer.call({ 'title' => 'T' })
      expect(result).not_to have_key(:codec)
    end
  end

  describe 'audio codec normalization' do
    it 'normalizes aac2.0 to AAC with channels' do
      result = normalizer.call({ 'audio' => 'aac2.0', 'title' => 'T' })
      expect(result[:audio]).to eq('AAC')
      expect(result[:channels]).to eq('2.0')
    end

    it 'normalizes dd5.1 to AC3 with channels' do
      result = normalizer.call({ 'audio' => 'dd5.1', 'title' => 'T' })
      expect(result[:audio]).to eq('AC3')
      expect(result[:channels]).to eq('5.1')
    end

    it 'normalizes ddp5.1 to E-AC3 with channels' do
      result = normalizer.call({ 'audio' => 'ddp5.1', 'title' => 'T' })
      expect(result[:audio]).to eq('E-AC3')
      expect(result[:channels]).to eq('5.1')
    end

    it 'normalizes dts-hd.ma.5.1 to DTS-HD Master' do
      result = normalizer.call({ 'audio' => 'dts-hd.ma.5.1', 'title' => 'T' })
      expect(result[:audio]).to eq('DTS-HD Master')
      expect(result[:channels]).to eq('5.1')
    end

    it 'normalizes truehd.7.1.atmos to TrueHD Atmos' do
      result = normalizer.call({ 'audio' => 'truehd.7.1.atmos', 'title' => 'T' })
      expect(result[:audio]).to eq('TrueHD Atmos')
      expect(result[:channels]).to eq('7.1')
    end

    it 'does not re-normalize already-final names' do
      result = normalizer.call({ 'audio' => 'AAC', 'title' => 'T' })
      expect(result[:audio]).to eq('AAC')
    end

    it 'skips normalization when audio is nil' do
      result = normalizer.call({ 'title' => 'T' })
      expect(result).not_to have_key(:audio)
    end

    it 'normalizes simple audio without channels' do
      result = normalizer.call({ 'audio' => 'flac', 'title' => 'T' })
      expect(result[:audio]).to eq('FLAC')
    end
  end

  describe 'source normalization' do
    it 'normalizes bluray to BD' do
      result = normalizer.call({ 'source' => 'BluRay', 'title' => 'T' })
      expect(result[:source]).to eq('BD')
    end

    it 'normalizes webrip to WEB' do
      result = normalizer.call({ 'source' => 'WEBRip', 'title' => 'T' })
      expect(result[:source]).to eq('WEB')
    end

    it 'normalizes hdtv to HDTV' do
      result = normalizer.call({ 'source' => 'HDTV', 'title' => 'T' })
      expect(result[:source]).to eq('HDTV')
    end

    it 'preserves unknown source as-is' do
      result = normalizer.call({ 'source' => 'UnknownSource', 'title' => 'T' })
      expect(result[:source]).to eq('UnknownSource')
    end

    it 'skips when source is nil' do
      result = normalizer.call({ 'title' => 'T' })
      expect(result).not_to have_key(:source)
    end
  end

  describe 'title normalization' do
    it 'replaces dots with spaces and titleizes' do
      result = normalizer.call({ 'title' => 'cool.movie' })
      expect(result[:title]).to eq('Cool Movie')
    end

    it 'replaces underscores with spaces and titleizes' do
      result = normalizer.call({ 'title' => 'cool_movie' })
      expect(result[:title]).to eq('Cool Movie')
    end

    it 'handles already-clean titles' do
      result = normalizer.call({ 'title' => 'Cool Movie' })
      expect(result[:title]).to eq('Cool Movie')
    end

    it 'titleizes episode_title' do
      result = normalizer.call({ 'title' => 'Show', 'episode_title' => 'cool.episode' })
      expect(result[:episode_title]).to eq('Cool Episode')
    end

    it 'removes empty episode_title' do
      result = normalizer.call({ 'title' => 'Show', 'episode_title' => '' })
      expect(result).not_to have_key(:episode_title)
    end

    it 'removes whitespace-only episode_title' do
      result = normalizer.call({ 'title' => 'Show', 'episode_title' => '  ' })
      expect(result).not_to have_key(:episode_title)
    end
  end
end
