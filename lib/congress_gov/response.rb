# frozen_string_literal: true

module CongressGov
  # Wraps a raw Faraday response body.
  # Handles the Congress.gov pagination envelope uniformly.
  # Includes +Enumerable+ so callers can iterate results directly.
  class Response
    include Enumerable

    # @return [Hash, Array, nil] the parsed JSON body.
    attr_reader :raw
    # @return [Integer] the HTTP status code.
    attr_reader :status

    # @param body [Hash, Array, nil] parsed response body.
    # @param status [Integer] HTTP status code.
    def initialize(body, status)
      @raw    = body || {}
      @status = status
    end

    # The primary results collection. Congress.gov uses different top-level keys
    # per endpoint ("members", "bills", "house-vote", etc.).
    # Returns the first Array value found in the body, falling back to [].
    #
    # @return [Array]
    def results
      return raw if raw.is_a?(Array)
      return [] unless raw.is_a?(Hash)

      array_value = raw.values.find { |v| v.is_a?(Array) }
      array_value || []
    end

    # Yields each result, enabling Enumerable methods on the response.
    #
    # @yield [Hash] each result item
    # @return [Enumerator] if no block given
    def each(&)
      results.each(&)
    end

    # Total number of matching records across all pages.
    #
    # @return [Integer, nil]
    def total_count
      raw.dig('pagination', 'count') if raw.is_a?(Hash)
    end

    # URL of the next page, or nil if on the last page.
    #
    # @return [String, nil]
    def next_url
      raw.dig('pagination', 'next') if raw.is_a?(Hash)
    end

    # URL of the previous page, or nil if on the first page.
    #
    # @return [String, nil]
    def prev_url
      raw.dig('pagination', 'prev') if raw.is_a?(Hash)
    end

    # Whether another page of results exists.
    #
    # @return [Boolean]
    def has_next_page?
      !next_url.nil?
    end

    # The offset for the next page, parsed from next_url.
    #
    # @return [Integer, nil]
    def next_offset
      return nil unless next_url

      uri    = URI.parse(next_url)
      params = URI.decode_www_form(uri.query.to_s).to_h
      params['offset']&.to_i
    end

    # Delegates key lookup to the raw response body.
    #
    # @param key [String] top-level key in the parsed JSON.
    # @return [Object, nil]
    def [](key)
      raw[key] if raw.is_a?(Hash)
    end

    # Returns the raw parsed response body as a Hash.
    #
    # @return [Hash, Array]
    def to_h
      raw
    end

    # Concise representation for debugging.
    #
    # @return [String]
    def inspect
      count = results.size
      total = total_count
      more  = has_next_page? ? ' has_next_page' : ''
      "#<#{self.class} status=#{status} results=#{count}#{"/#{total}" if total}#{more}>"
    end

    alias to_s inspect
  end
end
