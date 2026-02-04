# Plan: IML Gem Comprehensive Refactor

## Phase 1: Modernize Dependencies and Tooling

### Description
Update all dependencies to modern versions, replace Travis CI with GitHub Actions for testing, switch linting from RuboCop to StandardRB, and bump minimum Ruby version to 3.1+. This phase establishes the foundation for all subsequent changes.

### Steps

#### Step 1.1: Update Ruby Version Requirement and Gemspec
- **Objective**: Bump minimum Ruby to 3.1, modernize gemspec structure
- **Files**: `iml.gemspec`, `gemspec.yml`, `.ruby-version` (create)
- **Dependencies**: None
- **Implementation**:
  - Set `required_ruby_version` to `>= 3.1`
  - Update `activesupport` from `~> 5.2` to `~> 7.1`
  - Update `bundler` dev dependency to `~> 2.4`
  - Update `rake` to `~> 13.0`
  - Update `rspec` to `~> 3.13`
  - Replace `simplecov ~> 0.16` with `simplecov ~> 0.22`
  - Remove `codeclimate-test-reporter` (deprecated)
  - Remove `pry` dependency (use `irb` or `debug` gem instead)
  - Remove `tqdm` dependency (replace with Ruby-native progress in CLI)
  - Add `standard ~> 1.40` as dev dependency
  - Create `.ruby-version` file with `3.1.0`

#### Step 1.2: Replace Travis CI with GitHub Actions
- **Objective**: Modern CI pipeline with matrix testing
- **Files**: `.github/workflows/ci.yml` (create), `.travis.yml` (delete)
- **Dependencies**: Step 1.1
- **Implementation**:
  - Create GitHub Actions workflow for CI (Ruby 3.1, 3.2, 3.3)
  - Run `bundle exec rspec` and `bundle exec standardrb`
  - Remove `.travis.yml`

#### Step 1.3: Switch Linting to StandardRB
- **Objective**: Replace RuboCop with StandardRB for zero-config linting
- **Files**: `.rubocop.yml` (delete), `.standard.yml` (create)
- **Dependencies**: Step 1.1
- **Implementation**:
  - Remove `.rubocop.yml`
  - Create `.standard.yml` if any overrides needed
  - Update Rakefile to include StandardRB task

#### Step 1.4: Update Gemfile and Run Bundle Install
- **Objective**: Lock new dependency versions
- **Files**: `Gemfile`, `Gemfile.lock`
- **Dependencies**: Steps 1.1-1.3
- **Implementation**:
  - Update Gemfile if needed
  - Run `bundle install`
  - Verify all dependencies resolve

## Phase 2: Architecture Rewrite — Composition Over Inheritance

### Description
Replace OpenStruct inheritance with plain Ruby objects using composition. Eliminate `method_missing` reliance in favor of explicit interfaces. Replace `IML::Hash` with a simple configuration object. This phase fundamentally restructures the core domain model.

### Steps

#### Step 2.1: Create Configuration Module
- **Objective**: Replace `IML::Hash` and `IML::Patterns.config` with a proper configuration object
- **Files**: `lib/iml/configuration.rb` (create), `lib/iml/hash.rb` (delete)
- **Dependencies**: Phase 1 complete
- **Implementation**:
  - Create `IML::Configuration` class that loads `patterns.yml`
  - Use `Struct` or plain Ruby with explicit accessors instead of `HashWithIndifferentAccess`
  - Provide `IML.configuration` singleton method
  - Cache loaded config (load once, not on every pattern build)
  - Remove dependency on `activesupport/core_ext/hash`

#### Step 2.2: Rewrite Pattern Builder
- **Objective**: Replace `method_missing`-based pattern building with explicit methods
- **Files**: `lib/iml/pattern_builder.rb` (create), `lib/iml/patterns.rb` (rewrite)
- **Dependencies**: Step 2.1
- **Implementation**:
  - Create `IML::PatternBuilder` that constructs regex from config
  - Explicit methods for each pattern component (`title_pattern`, `year_pattern`, etc.)
  - Move pattern templates (movie/tv formats) into config or constants
  - Remove `method_missing` / `respond_to_missing?` from patterns
  - Return frozen Regexp objects

#### Step 2.3: Create Media Result Value Objects
- **Objective**: Replace OpenStruct-based Base/Movie/TVSeries with composition-based value objects
- **Files**: `lib/iml/media/result.rb` (create), `lib/iml/media/movie.rb` (create), `lib/iml/media/tv_series.rb` (create)
- **Dependencies**: Step 2.1
- **Implementation**:
  - Create `IML::Media::Result` as a plain Ruby class with explicit attributes
  - Use `Data.define` (Ruby 3.2+) or `Struct` for immutable value objects
  - Compose with a `Formatter` for output path generation (not inherited)
  - Compose with a `Normalizer` for codec/audio normalization
  - `IML::Media::Movie` and `IML::Media::TvSeries` as specialized result types
  - Remove all OpenStruct usage

#### Step 2.4: Create Formatter Service
- **Objective**: Extract output path formatting into a dedicated service
- **Files**: `lib/iml/formatter.rb` (create)
- **Dependencies**: Step 2.3
- **Implementation**:
  - Create `IML::Formatter` that takes a result and format string
  - `call(result, format: nil)` returns formatted string
  - Placeholder definitions live with the formatter, not the model
  - Support custom format strings

#### Step 2.5: Create Normalizer Service
- **Objective**: Extract codec/audio normalization into a dedicated service
- **Files**: `lib/iml/normalizer.rb` (create)
- **Dependencies**: Steps 2.1, 2.3
- **Implementation**:
  - Create `IML::Normalizer` that normalizes codec and audio names
  - `call(attributes)` returns normalized attribute hash
  - Uses config for lookup tables
  - Handles title case conversion

#### Step 2.6: Rewrite Parser (formerly Text)
- **Objective**: Replace `IML::Text < String` with a proper parser using composition
- **Files**: `lib/iml/parser.rb` (create), `lib/iml/text.rb` (delete)
- **Dependencies**: Steps 2.2, 2.3, 2.5
- **Implementation**:
  - Create `IML::Parser` class (does not inherit from String)
  - `parse(filename)` returns `Media::Movie`, `Media::TvSeries`, or `nil`
  - Inject pattern builder and normalizer
  - Clean separation: parsing, normalization, and result creation are distinct steps

#### Step 2.7: Create File Mover Service
- **Objective**: Extract file operations from Base into a dedicated service
- **Files**: `lib/iml/file_mover.rb` (create)
- **Dependencies**: Steps 2.3, 2.4
- **Implementation**:
  - Create `IML::FileMover` service
  - `call(source_path, result, format: nil, target: nil, pretend: false)`
  - Handles directory creation, file moving, error handling
  - Returns result object (success/failure) instead of integer codes

#### Step 2.8: Update Main Entry Point
- **Objective**: Wire up new architecture in `lib/iml.rb`
- **Files**: `lib/iml.rb` (rewrite)
- **Dependencies**: Steps 2.1-2.7
- **Implementation**:
  - Remove old requires (text, base, movie, tvseries, hash)
  - Add new requires (configuration, parser, formatter, normalizer, file_mover, media/*)
  - Provide `IML.parse(filename)` convenience method
  - Provide `IML.configuration` accessor
  - Remove conditional `pry` require
  - Remove `puts` for missing iml-imdb (use proper logging or silence)

#### Step 2.9: Delete Legacy Files
- **Objective**: Remove old architecture files
- **Files**: `lib/iml/base.rb`, `lib/iml/text.rb`, `lib/iml/movie.rb`, `lib/iml/tvseries.rb`, `lib/iml/hash.rb` (all delete)
- **Dependencies**: Steps 2.6-2.8
- **Implementation**:
  - Delete all legacy class files
  - Verify no remaining references

## Phase 3: CLI Modernization

### Description
Rewrite the CLI script to use the new architecture, add `--version` flag, remove `tqdm` dependency, and improve error handling.

### Steps

#### Step 3.1: Rewrite CLI Script
- **Objective**: Modern CLI using new architecture with proper structure
- **Files**: `bin/iml` (rewrite)
- **Dependencies**: Phase 2 complete
- **Implementation**:
  - Add `--version` / `-V` flag (print `IML::VERSION` and exit)
  - Replace `tqdm` progress bar with simple STDERR output or `$stderr.print`
  - Use `IML::Parser` and `IML::FileMover` services
  - Move `file_operations` from top-level method into a CLI class or module
  - Proper exit codes (0 success, 1 error)
  - Replace `Logger.new(STDOUT)` with configurable logger
  - Handle SIGINT gracefully

## Phase 4: Remove ActiveSupport Dependency

### Description
Replace remaining ActiveSupport usage with lightweight Ruby equivalents to eliminate the heavy dependency.

### Steps

#### Step 4.1: Replace ActiveSupport Inflector
- **Objective**: Remove `titleize` dependency on ActiveSupport
- **Files**: `lib/iml/utils.rb` (create)
- **Dependencies**: Phase 2 complete
- **Implementation**:
  - Create `IML::Utils.titleize(string)` — simple implementation
  - Replace `.titleize` calls with `IML::Utils.titleize`
  - Verify edge cases match expected behavior

#### Step 4.2: Remove HashWithIndifferentAccess Usage
- **Objective**: Eliminate remaining ActiveSupport hash dependency
- **Files**: Various (already handled in Phase 2 config rewrite)
- **Dependencies**: Step 2.1
- **Implementation**:
  - Verify `IML::Configuration` uses plain Ruby hashes with string keys
  - Use `transform_keys(&:to_s)` or `symbolize_keys` as needed
  - Remove `require 'active_support/core_ext/hash'`

#### Step 4.3: Remove ActiveSupport from Gemspec
- **Objective**: Drop the activesupport runtime dependency entirely
- **Files**: `gemspec.yml`, `lib/iml.rb`
- **Dependencies**: Steps 4.1-4.2
- **Implementation**:
  - Remove `activesupport` from dependencies in `gemspec.yml`
  - Remove all `require 'active_support/*'` lines
  - Run tests to verify nothing breaks

## Phase 5: Comprehensive Test Suite

### Description
Rewrite the test suite to match the new architecture with thorough coverage, proper organization, and `:verified` tags.

### Steps

#### Step 5.1: Set Up Test Infrastructure
- **Objective**: Modern RSpec configuration with proper helpers
- **Files**: `spec/spec_helper.rb` (rewrite), `.rspec` (update)
- **Dependencies**: Phase 2 complete
- **Implementation**:
  - Configure SimpleCov with minimum coverage threshold
  - Add `:verified` tag filtering
  - Set up shared contexts for common test data
  - Create `spec/support/` directory for shared examples

#### Step 5.2: Test Configuration
- **Objective**: Full coverage of pattern configuration loading
- **Files**: `spec/configuration_spec.rb` (create)
- **Dependencies**: Step 5.1
- **Implementation**:
  - Test config loads from YAML
  - Test all config keys accessible
  - Test caching behavior
  - Test with missing/malformed config file

#### Step 5.3: Test Pattern Builder
- **Objective**: Full coverage of regex pattern construction
- **Files**: `spec/pattern_builder_spec.rb` (create)
- **Dependencies**: Step 5.1
- **Implementation**:
  - Test each pattern component generates valid regex
  - Test movie patterns match expected filenames
  - Test TV patterns match expected filenames
  - Test patterns reject non-matching filenames
  - Edge cases: special characters, unusual formats

#### Step 5.4: Test Parser
- **Objective**: Comprehensive filename parsing tests
- **Files**: `spec/parser_spec.rb` (create)
- **Dependencies**: Step 5.1
- **Implementation**:
  - Test movie detection with various formats
  - Test TV series detection with various formats
  - Test unrecognized filenames return nil
  - Test edge cases: missing fields, unusual separators, 4K content
  - Test with real-world filename examples

#### Step 5.5: Test Media Result Objects
- **Objective**: Full coverage of value objects
- **Files**: `spec/media/movie_spec.rb` (create), `spec/media/tv_series_spec.rb` (create)
- **Dependencies**: Step 5.1
- **Implementation**:
  - Test attribute access
  - Test immutability (if using Data.define)
  - Test type predicates (`movie?`, `tv?`)
  - Test season_i / episode_i for TV series

#### Step 5.6: Test Formatter
- **Objective**: Full coverage of output path formatting
- **Files**: `spec/formatter_spec.rb` (create)
- **Dependencies**: Step 5.1
- **Implementation**:
  - Test default format strings for movie and TV
  - Test custom format strings
  - Test all placeholder substitutions
  - Test with missing attributes (graceful handling)

#### Step 5.7: Test Normalizer
- **Objective**: Full coverage of codec/audio normalization
- **Files**: `spec/normalizer_spec.rb` (create)
- **Dependencies**: Step 5.1
- **Implementation**:
  - Test video codec normalization (x264 -> h.264, etc.)
  - Test audio codec normalization with channels
  - Test title case conversion
  - Test unknown codecs pass through unchanged

#### Step 5.8: Test File Mover
- **Objective**: Full coverage of file operations
- **Files**: `spec/file_mover_spec.rb` (create)
- **Dependencies**: Step 5.1
- **Implementation**:
  - Test directory creation
  - Test file moving
  - Test pretend mode (no actual operations)
  - Test error handling (missing source, permission errors)
  - Use tmpdir for actual file operations

#### Step 5.9: Delete Legacy Tests
- **Objective**: Remove old test file
- **Files**: `spec/iml_spec.rb` (delete)
- **Dependencies**: Steps 5.2-5.8
- **Implementation**:
  - Delete monolithic test file
  - Verify all test scenarios covered by new specs
  - Run full suite to confirm green

## Phase 6: Final Cleanup and Verification

### Description
Run all linters and tests, verify the gem builds, update documentation, and ensure everything is release-ready.

### Steps

#### Step 6.1: Run StandardRB and Fix Issues
- **Objective**: Zero linting warnings
- **Files**: Various (auto-fix)
- **Dependencies**: Phases 1-5 complete
- **Implementation**:
  - Run `bundle exec standardrb --fix .`
  - Review and manually fix any remaining issues
  - Ensure all files have `frozen_string_literal: true`

#### Step 6.2: Run Full Test Suite
- **Objective**: All tests pass with good coverage
- **Files**: None (verification only)
- **Dependencies**: Step 6.1
- **Implementation**:
  - Run `bundle exec rspec`
  - Verify coverage meets threshold
  - Fix any failures

#### Step 6.3: Build and Verify Gem
- **Objective**: Gem builds cleanly
- **Files**: None (verification only)
- **Dependencies**: Step 6.2
- **Implementation**:
  - Run `gem build iml.gemspec`
  - Verify gem file contents are correct
  - Test `gem install` locally

#### Step 6.4: Update README
- **Objective**: Documentation reflects new architecture and usage
- **Files**: `README.md`
- **Dependencies**: Step 6.2
- **Implementation**:
  - Update usage examples to new API (`IML.parse`)
  - Update dependency requirements (Ruby 3.1+)
  - Document new CLI flags (`--version`)
  - Remove references to ActiveSupport
