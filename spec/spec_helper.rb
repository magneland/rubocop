# frozen_string_literal: true

# Disable colors in specs
require 'rainbow'
Rainbow.enabled = false

require 'rubocop'
require 'rubocop/cop/internal_affairs'

require 'webmock/rspec'

require_relative 'core_ext/string'

# Require supporting files exposed for testing.
require 'rubocop/rspec/support'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  unless defined?(::TestQueue)
    # See. https://github.com/tmm1/test-queue/issues/60#issuecomment-281948929
    config.filter_run :focus
    config.run_all_when_everything_filtered = true
  end

  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!

  config.include RuboCop::RSpec::ExpectOffense

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect # Disable `should`
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect # Disable `should_receive` and `stub`
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    RuboCop::Cop::Registry.global.freeze
    # This ensures that there are no side effects from running a particular spec.
    # Use `:restore_registry` / `RuboCop::Cop::Registry.with_temporary_global` if
    # need to modify registry (e.g. with `stub_cop_class`).
  end

  config.after(:suite) do
    RuboCop::Cop::Registry.reset!
  end

  if %w[ruby-head-ascii_spec ruby-head-spec].include? ENV['CIRCLE_STAGE']
    config.filter_run_excluding broken_on: :ruby_head
  end

  if %w[jruby-9.2-ascii_spec jruby-9.2-spec].include? ENV['CIRCLE_STAGE']
    config.filter_run_excluding broken_on: :jruby
  end
end
