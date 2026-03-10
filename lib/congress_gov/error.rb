# frozen_string_literal: true

module CongressGov
  # Base error class. All gem errors inherit from this.
  class Error < StandardError; end

  # Raised when api_key is missing or blank.
  class ConfigurationError < Error; end

  # Raised on 4xx responses (excluding 429).
  class ClientError < Error
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      @status = status
      @body   = body
      super(message || "HTTP #{status}: #{body}")
    end
  end

  # Raised on 403 — usually means invalid or missing API key.
  class AuthenticationError < ClientError; end

  # Raised on 404.
  class NotFoundError < ClientError; end

  # Raised on 429 after retries are exhausted.
  class RateLimitError < ClientError; end

  # Raised on 5xx responses.
  class ServerError < Error
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      @status = status
      @body   = body
      super(message || "Server error HTTP #{status}")
    end
  end

  # Raised on network-level failures (timeout, connection refused).
  class ConnectionError < Error; end

  # Raised when Clerk XML cannot be parsed or is malformed.
  class ParseError < Error; end
end
