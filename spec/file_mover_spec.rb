RSpec.describe IML::FileMover, :verified do
  subject(:mover) { described_class.new }

  let(:movie) do
    IML::Media::Movie.new(
      title: "Cool Movie", year: "2018", extension: "mp4"
    )
  end

  describe "#call" do
    context "in pretend mode" do
      it "returns destination Pathname" do
        dest = mover.call("source.mp4", movie, pretend: true)
        expect(dest).to be_a(Pathname)
        expect(dest.to_s).to eq("Cool Movie (2018).mp4")
      end

      it "does not create directories" do
        expect(FileUtils).not_to receive(:mkdir_p)
        expect(FileUtils).not_to receive(:mv)
        mover.call("source.mp4", movie, pretend: true)
      end

      it "respects target option" do
        dest = mover.call("source.mp4", movie, target: "/output", pretend: true)
        expect(dest.to_s).to eq("/output/Cool Movie (2018).mp4")
      end

      it "respects format option" do
        dest = mover.call("source.mp4", movie, format: "%T.%f", pretend: true)
        expect(dest.to_s).to eq("Cool Movie.mp4")
      end
    end

    context "with actual files" do
      let(:tmpdir) { Dir.mktmpdir }
      let(:source_file) { File.join(tmpdir, "source.mp4") }

      before { FileUtils.touch(source_file) }
      after { FileUtils.rm_rf(tmpdir) }

      it "moves file to destination" do
        dest = mover.call(source_file, movie, target: tmpdir)
        expect(dest).to be_a(Pathname)
        expect(File.exist?(dest)).to be(true)
        expect(File.exist?(source_file)).to be(false)
      end

      it "creates destination directory" do
        tv = IML::Media::TvSeries.new(
          title: "Show", season: "01", episode: "01", extension: "mkv"
        )
        source = File.join(tmpdir, "source.mkv")
        FileUtils.touch(source)

        dest = mover.call(source, tv, target: tmpdir)
        expect(File.exist?(dest)).to be(true)
        expect(dest.dirname.exist?).to be(true)
      end
    end

    context "error handling" do
      it "raises FileNotFoundError for missing source" do
        expect { mover.call("/nonexistent/file.mp4", movie) }
          .to raise_error(IML::FileNotFoundError)
      end

      it "wraps Errno::ENOENT" do
        expect { mover.call("/nonexistent/file.mp4", movie) }
          .to raise_error(IML::Error)
      end
    end

    context "with custom formatter" do
      it "accepts injected formatter" do
        formatter = IML::Formatter.new
        custom_mover = described_class.new(formatter: formatter)
        dest = custom_mover.call("source.mp4", movie, pretend: true)
        expect(dest.to_s).to eq("Cool Movie (2018).mp4")
      end
    end
  end
end
