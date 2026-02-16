# frozen_string_literal: true

module IML
  class FileMover
    def initialize(formatter: IML::Formatter.new)
      @formatter = formatter
    end

    def call(source_path, media, format: nil, target: nil, pretend: false)
      dest = @formatter.pathname(media, format: format, target: target)

      unless pretend
        FileUtils.mkdir_p(dest.dirname)
        FileUtils.mv(source_path.to_s, dest.to_s)
      end

      dest
    rescue Errno::ENOENT => e
      raise IML::FileNotFoundError, e.message
    end
  end
end
