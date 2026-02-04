[![Gem Version](https://img.shields.io/gem/v/iml.svg)](https://rubygems.org/gems/iml)

[![IML](https://github.com/aladac/iml/raw/master/doc/iml-logo.png)](https://rubygems.org/gems/iml)

*Intricate (Media) Matching Logic*

A media file handling library that detects the type of media file based on naming patterns.
It parses filenames into structured objects and renames files according to configurable format strings.
Includes an `iml` CLI for batch rename operations.

**Zero runtime dependencies.**

## Installation

Requires Ruby >= 3.1

Add this line to your application's Gemfile:

```ruby
gem "iml"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iml

## Usage

### Command Line

```
Usage: iml [options] MEDIA_FILE [MEDIA_FILE] ...
    -v, --[no-]verbose               Run verbosely
    -p, --[no-]pretend               Dry run, do not move any files
    -t, --target PATH                Output directory (default: current directory)
    -o, --movie-format FORMAT        Movie output format (default: '%T (%Y).%f')
    -O, --tv-format FORMAT           TV series output format (default: '%T/Season %s/%T - S%SE%E.%f')
    -l, --list-formats               Show format placeholders
    -f, --force                      Overwrite existing output files
    -V, --version                    Show version

$ iml --pretend --verbose Some.Cool.Movie.2018.1080p.BRRip.x264.aac-GROUP.mp4
movie: Some.Cool.Movie.2018.1080p.BRRip.x264.aac-GROUP.mp4 -> Some Cool Movie (2018).mp4
done: 1 processed, 0 skipped
```

### Library

```ruby
require "iml"

# Parse a movie filename
movie = IML.parse("Cool.Movie.2018.720p.BluRay.H264.AAC2.0-GROUP.mp4")
movie.class     #=> IML::Media::Movie
movie.title     #=> "Cool Movie"
movie.year      #=> "2018"
movie.codec     #=> "h.264"
movie.source    #=> "BD"
movie.movie?    #=> true

# Parse a TV series filename
tv = IML.parse("Show.Name.S03E09.WEBRip.x264-GROUP.mkv")
tv.class        #=> IML::Media::TvSeries
tv.title        #=> "Show Name"
tv.season       #=> "03"
tv.season_i     #=> 3
tv.episode_i    #=> 9
tv.tv?          #=> true

# Format output paths
formatter = IML::Formatter.new
formatter.call(movie)                          #=> "Cool Movie (2018).mp4"
formatter.call(movie, format: "%T/%T.%Y.%f")  #=> "Cool Movie/Cool Movie.2018.mp4"
formatter.pathname(movie, target: "/media")    #=> #<Pathname:/media/Cool Movie (2018).mp4>

# Move files
mover = IML::FileMover.new
mover.call("source.mp4", movie, target: "/media", pretend: true)
```

### Format Placeholders

| Placeholder | Description |
|-------------|-------------|
| `%T` | Title |
| `%t` | Episode title |
| `%Y` | Year |
| `%S` | Season (string, e.g. "03") |
| `%s` | Season (integer, e.g. "3") |
| `%E` | Episode (string, e.g. "09") |
| `%e` | Episode (integer, e.g. "9") |
| `%v` | Video codec |
| `%a` | Audio codec |
| `%q` | Quality |
| `%z` | Source |
| `%g` | Group |
| `%f` | File extension |

## Architecture

```
IML.parse(filename)
  -> IML::Parser
       -> IML::PatternBuilder  (builds regex from patterns.yml)
       -> IML::Normalizer      (normalizes codecs, sources, titles)
       -> IML::Media::Movie or IML::Media::TvSeries

IML::Formatter    (formats output paths from media objects)
IML::FileMover    (moves files using Formatter)
IML::Configuration (loads patterns.yml)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
