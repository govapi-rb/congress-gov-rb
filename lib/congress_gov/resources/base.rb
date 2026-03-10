# frozen_string_literal: true

module CongressGov
  # Namespace for all Congress.gov API resource classes.
  module Resources
    # Abstract base class for all Congress.gov resource endpoints.
    # Provides a shared client reference, a convenience +get+ wrapper,
    # and generic auto-pagination via {#each_page} and {#paginate}.
    class Base
      # Creates a new resource bound to the given client.
      #
      # @param client [CongressGov::Client] the HTTP client to use.
      def initialize(client = CongressGov.client)
        @client = client
      end

      # Iterate through every page of a paginated endpoint.
      # Yields each {CongressGov::Response} page.
      #
      # @param path [String] API path.
      # @param params [Hash] query parameters (should include :limit).
      # @yield [CongressGov::Response] each page of results.
      # @return [Enumerator] if no block given.
      #
      # @example
      #   CongressGov.bill.each_page('bill/119', limit: 250) do |page|
      #     page.results.each { |bill| process(bill) }
      #   end
      def each_page(path, params = {}, &block)
        return enum_for(:each_page, path, params) unless block

        limit  = params.fetch(:limit, 20)
        offset = params.fetch(:offset, 0)

        loop do
          response = client.get(path, params.merge(limit: limit, offset: offset))
          yield response
          break unless response.has_next_page?

          offset += limit
        end
      end

      # Collect all results across all pages of a paginated endpoint.
      # Returns a flat Array of all result hashes.
      #
      # @param path [String] API path.
      # @param params [Hash] query parameters.
      # @return [Array<Hash>] all results across all pages.
      #
      # @example
      #   all_bills = CongressGov.bill.paginate('bill/119/hr', limit: 250)
      def paginate(path, params = {})
        results = []
        each_page(path, params) { |page| results.concat(page.results) }
        results
      end

      private

      # @return [CongressGov::Client]
      attr_reader :client

      # Shorthand for {Client#get}.
      #
      # @param path [String] API path relative to the base URL.
      # @param params [Hash] optional query parameters.
      # @return [CongressGov::Response]
      def get(path, params = {})
        client.get(path, params)
      end
    end
  end
end
