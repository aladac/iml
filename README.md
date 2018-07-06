[![Gem Version](https://img.shields.io/gem/v/iml.svg)](https://rubygems.org/gems/iml)
[![build status](https://travis-ci.org/aladac/iml.svg?branch=master)](https://travis-ci.org/aladac/iml)
[![Maintainability](https://api.codeclimate.com/v1/badges/232800c6e4d8778937b2/maintainability)](https://codeclimate.com/github/aladac/iml/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/232800c6e4d8778937b2/test_coverage)](https://codeclimate.com/github/aladac/iml/test_coverage)

[![IML](https://github.com/aladac/iml/raw/master/doc/ilm-logo.png)](https://rubygems.org/gems/iml)

*Intricate (Media) Matching Logic*

This is a media file handling library which is supposed to "guess" the intended type of media file based on specific naming patterns.
Its main purpose is to serve as runtime for renaming media files according to specified patterns.
The gem includes an executable `iml` through which rename operations are possible.

## Installation

This gem requires ruby >= 2.4

Add this line to your application's Gemfile:

```ruby
gem 'iml'
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
    -t, --target PATH                Path to move media files to, default: current directory
    -o, --movie-format FORMAT        Format of the output path of movies, default: '%T (%Y).%f'
    -O, --tv-format FORMAT           Format of the output path of TV series, default: '%T/Season %s/%T - S%SE%E.%f'
    -l, --list-formats               Format description
    -f, --force                      Use the force, override output files

$ iml -v Some.Cool.Movie.2018.1080p.BRRip.x264.aac-GROUP.mp4
I, [2018-07-06T13:38:29.836887 #70771]  INFO -- : Some.Cool.Movie.2018.1080p.BRRip.x264.aac-GROUP.mp4 looks like a movie
I, [2018-07-06T13:38:29.837047 #70771]  INFO -- : Moving Some.Cool.Movie.2018.1080p.BRRip.x264.aac-GROUP.mp4 to Some Cool Movie (2018).mp4
```

### Code

```ruby
title = "An.Interesting.TV.Show.S01E01.1080p.WEBRIP.h265-GROUP.mkv"
=> "An.Interesting.TV.Show.S01E01.1080p.WEBRIP.h265-GROUP.mkv"
IML::Text.new(title).detect
=> #<IML::TVSeries title="An Interesting Tv Show", season="01", episode="01", quality="1080p", source="WEBRIP", codec="h265", group="GROUP", extension="mkv">
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
