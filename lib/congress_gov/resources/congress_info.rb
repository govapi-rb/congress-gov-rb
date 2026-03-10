# frozen_string_literal: true

module CongressGov
  module Resources
    # Access Congress session data from the Congress.gov API.
    class CongressInfo < Base
      # List all congresses.
      #
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list(limit: 20, offset: 0)
        client.get('congress', { limit: limit, offset: offset })
      end

      # Fetch details for a specific congress.
      #
      # @param congress [Integer] e.g. 119
      # @return [CongressGov::Response]
      def get(congress)
        client.get("congress/#{congress}")
      end

      # Fetch the current congress.
      #
      # @return [CongressGov::Response]
      def current
        client.get('congress/current')
      end
    end
  end
end
