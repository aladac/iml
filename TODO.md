# TODO: IML Gem Comprehensive Refactor

## Phase 1: Modernize Dependencies and Tooling
- [x] Step 1.1: Update Ruby version requirement and gemspec
- [x] Step 1.2: Replace Travis CI with GitHub Actions
- [x] Step 1.3: Switch linting to StandardRB
- [x] Step 1.4: Update Gemfile and run bundle install

## Phase 2: Architecture Rewrite — Composition Over Inheritance
- [x] Step 2.1: Create Configuration module (replace IML::Hash)
- [x] Step 2.2: Rewrite Pattern Builder (remove method_missing)
- [x] Step 2.3: Create Media Result value objects (replace OpenStruct)
- [x] Step 2.4: Create Formatter service
- [x] Step 2.5: Create Normalizer service
- [x] Step 2.6: Rewrite Parser (replace IML::Text < String)
- [x] Step 2.7: Create File Mover service
- [x] Step 2.8: Update main entry point (lib/iml.rb)
- [x] Step 2.9: Delete legacy files

## Phase 3: CLI Modernization
- [x] Step 3.1: Rewrite CLI script (add --version, remove tqdm, proper exit codes)

## Phase 4: Remove ActiveSupport Dependency
- [x] Step 4.1: Replace ActiveSupport Inflector with lightweight titleize
- [x] Step 4.2: Remove HashWithIndifferentAccess usage
- [x] Step 4.3: Remove activesupport from gemspec

## Phase 5: Comprehensive Test Suite
- [x] Step 5.1: Set up test infrastructure (spec_helper, :verified tags)
- [x] Step 5.2: Test Configuration
- [x] Step 5.3: Test Pattern Builder
- [x] Step 5.4: Test Parser
- [x] Step 5.5: Test Media Result objects (Movie, TvSeries)
- [x] Step 5.6: Test Formatter
- [x] Step 5.7: Test Normalizer
- [x] Step 5.8: Test File Mover
- [x] Step 5.9: Delete legacy tests

## Phase 6: Final Cleanup and Verification
- [x] Step 6.1: Run StandardRB and fix issues
- [x] Step 6.2: Run full test suite
- [x] Step 6.3: Build and verify gem
- [x] Step 6.4: Update README
