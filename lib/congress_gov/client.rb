# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'faraday/http_cache'
require 'json'

module CongressGov
  # Low-level HTTP client that wraps Faraday for Congress.gov API requests.
  # Handles authentication, retries, timeout, and error mapping.
  class Client
    # @return [CongressGov::Configuration]
    attr_reader :config

    # Creates a new client and validates the configuration.
    #
    # @param config [CongressGov::Configuration] configuration to use.
    def initialize(config = CongressGov.configuration)
      @config = config
      config.validate!
    end

    # Returns a memoized Faraday connection configured for the Congress.gov API.
    #
    # @return [Faraday::Connection]
    def connection
      @connection ||= Faraday.new(url: config.base_url) do |f|
        f.options.timeout      = config.timeout
        f.options.open_timeout = 10

        # Inject API key into every request as a query param
        f.request :url_encoded
        f.response :json, content_type: /\bjson$/

        if config.cache_store
          f.use :http_cache,
                store: config.cache_store,
                shared_cache: false
        end

        f.request :retry,
                  max: config.retries,
                  interval: 1.0,
                  interval_randomness: 0.5,
                  backoff_factor: 2,
                  retry_statuses: [429, 500, 502, 503, 504],
                  exceptions: [
                    Faraday::TimeoutError,
                    Faraday::ConnectionFailed,
                    Faraday::RetriableResponse
                  ]

        f.response :logger, config.logger if config.logger
        f.adapter config.adapter
      end
    end

    # Plain HTTP client for fetching Clerk XML — no auth, no JSON parsing.
    def clerk_connection
      @clerk_connection ||= Faraday.new(url: config.clerk_base_url) do |f|
        f.options.timeout      = config.timeout
        f.options.open_timeout = 10
        f.adapter config.adapter
      end
    end

    # GET request — automatically appends api_key to params.
    #
    # @param path   [String]
    # @param params [Hash]
    # @return [CongressGov::Response]
    def get(path, params = {})
      response = connection.get(path, params.merge(api_key: config.api_key, format: 'json'))
      handle_response(response)
    rescue Faraday::TimeoutError => e
      raise ConnectionError, "Request timed out: #{e.message}"
    rescue Faraday::ConnectionFailed => e
      raise ConnectionError, "Connection failed: #{e.message}"
    end

    # Fetch raw XML from clerk.house.gov. Returns the raw body string.
    # Does not raise on HTTP errors — callers handle nil/blank responses.
    #
    # @param path [String] e.g. "2025/roll281.xml"
    # @return [String, nil]
    def get_clerk_xml(path)
      response = clerk_connection.get(path)
      return nil unless response.status == 200

      response.body
    rescue Faraday::Error
      nil
    end

    private

    # Maps an HTTP response to a {Response} or raises an appropriate error.
    #
    # @param response [Faraday::Response]
    # @return [CongressGov::Response]
    # @raise [CongressGov::Error] on non-2xx status codes.
    def handle_response(response)
      case response.status
      when 200..299
        Response.new(response.body, response.status)
      when 403
        raise AuthenticationError.new(
          'Invalid or missing API key',
          status: 403,
          body: response.body
        )
      when 404
        raise NotFoundError.new(status: 404, body: response.body)
      when 429
        raise RateLimitError.new('Rate limit exceeded', status: 429, body: response.body)
      when 400..499
        raise ClientError.new(status: response.status, body: response.body)
      when 500..599
        raise ServerError.new(status: response.status, body: response.body)
      else
        raise Error, "Unexpected HTTP status: #{response.status}"
      end
    end
  end
end
