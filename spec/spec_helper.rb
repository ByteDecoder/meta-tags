# frozen_string_literal: true

if ENV['ENABLE_CODE_COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'meta_tags'
require 'rspec-html-matchers'

RSpec.configure do |config|
  if config.files_to_run.one?
    # RSpec filters the backtrace by default so as not to be so noisy.
    # This causes the full backtrace to be printed when running a single
    # spec file (e.g. to troubleshoot a particular spec failure).
    config.full_backtrace = true

    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.formatter = 'doc' if config.formatters.none?
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.include RSpecHtmlMatchers

  # Reset MetaTags configuration after every spec.
  config.after do
    MetaTags.config.reset_defaults!
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
    expectations.syntax = :expect
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end
end

shared_examples_for '.set_meta_tags' do
  context 'with a Hash parameter' do
    it 'updates meta tags' do
      subject.set_meta_tags(title: 'hello')
      expect(subject.meta_tags[:title]).to eq('hello')

      subject.set_meta_tags(title: 'world')
      expect(subject.meta_tags[:title]).to eq('world')
    end
  end

  context 'with an Object responding to #to_meta_tags parameter' do
    it 'updates meta tags' do
      object1 = double(to_meta_tags: { title: 'hello' })
      object2 = double(to_meta_tags: { title: 'world' })

      subject.set_meta_tags(object1)
      expect(subject.meta_tags[:title]).to eq('hello')

      subject.set_meta_tags(object2)
      expect(subject.meta_tags[:title]).to eq('world')
    end
  end

  it 'uses deep merge when updating meta tags' do
    subject.set_meta_tags(og: { title: 'hello' })
    expect(subject.meta_tags[:og]).to eq('title' => 'hello')

    subject.set_meta_tags(og: { description: 'world' })
    expect(subject.meta_tags[:og]).to eq('title' => 'hello', 'description' => 'world')

    subject.set_meta_tags(og: { admin: { id: 1 } })
    expect(subject.meta_tags[:og]).to eq('title' => 'hello', 'description' => 'world', 'admin' => { 'id' => 1 })
  end

  it 'normalizes :open_graph to :og' do
    subject.set_meta_tags(open_graph: { title: 'hello' })
    expect(subject.meta_tags[:og]).to eq('title' => 'hello')
  end
end
