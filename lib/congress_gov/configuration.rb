# frozen_string_literal: true

module CongressGov
  # Stores runtime settings for the CongressGov client.
  # Use {CongressGov.configure} to modify these values.
  class Configuration
    # Default base URL for the Congress.gov API.
    DEFAULT_BASE_URL  = 'https://api.congress.gov/v3/'
    # Default HTTP timeout in seconds.
    DEFAULT_TIMEOUT   = 30
    # Default number of automatic retries on transient failures.
    DEFAULT_RETRIES   = 3
    # Base URL for the House Clerk electronic voting system.
    CLERK_BASE_URL    = 'https://clerk.house.gov/evs/'

    # @return [String, nil] API key used to authenticate requests.
    # @return [String] base URL for the Congress.gov API.
    # @return [String] base URL for the House Clerk voting site.
    # @return [Integer] HTTP timeout in seconds.
    # @return [Integer] number of automatic retries on transient failures.
    # @return [Logger, nil] optional logger for request/response debugging.
    # @return [Symbol] Faraday adapter to use for HTTP requests.
    attr_accessor :api_key, :base_url, :clerk_base_url,
                  :timeout, :retries, :logger, :adapter,
                  :cache_store

    # Initializes a new Configuration with sensible defaults.
    # Reads +CONGRESS_GOV_API_KEY+ from the environment when available.
    def initialize
      @api_key        = ENV.fetch('CONGRESS_GOV_API_KEY', nil)
      @base_url       = DEFAULT_BASE_URL
      @clerk_base_url = CLERK_BASE_URL
      @timeout        = DEFAULT_TIMEOUT
      @retries        = DEFAULT_RETRIES
      @logger         = nil
      @adapter        = Faraday.default_adapter
      @cache_store    = nil
    end

    # Raises {ConfigurationError} unless a valid API key is present.
    #
    # @return [void]
    # @raise [ConfigurationError] if api_key is nil or empty.
    def validate!
      raise ConfigurationError, 'api_key is required' if api_key.nil? || api_key.empty?
    end
  end
end
