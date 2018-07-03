RSpec.describe IML do
  it "has a version number" do
    expect(IML::VERSION).not_to be nil
  end
  context 'Base' do
    it '#new initializes a new object' do
      expect(IML::Base.new).to be_an(IML::Base)
    end
  end
  context 'String' do
    it '#new initializes a new object' do
      expect(IML::String.new).to be_an(IML::String)
    end

    it '#movie? returns a positive result' do
      title = 'Snowblind.2010.720p.BluRay.H264.AAC-RARBG.mp4'
      expect(IML::String.new(title).movie?).to be_an(IML::Movie)
    end

    it '#movie? returns a negative result' do
      title = 'foobar foobar'
      expect(IML::String.new(title).movie?).to be(false)
    end

    it '#tv? returns a positive result' do
      title = 'Walk.the.Prank.S03E09.WEBRip.x264-ION10.mkv'
      expect(IML::String.new(title).tv?).to be_an(IML::TVSeries)
    end

    it '#tv? returns a negative result' do
      title = 'foobar foobar'
      expect(IML::String.new(title).tv?).to be(false)
    end
  end
end
