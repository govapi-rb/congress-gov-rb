# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false

  config.default_cassette_options = {
    record: ENV['VCR_RECORD'] ? :new_episodes : :none,
    match_requests_on: %i[method uri]
  }

  # Scrub the real API key from cassettes so they're safe to commit
  config.filter_sensitive_data('<CONGRESS_API_KEY>') { ENV.fetch('CONGRESS_GOV_API_KEY', 'test_api_key_for_vcr') }
end
