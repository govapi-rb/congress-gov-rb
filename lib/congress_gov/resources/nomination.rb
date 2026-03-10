# frozen_string_literal: true

module CongressGov
  module Resources
    # Access nomination data from the Congress.gov API.
    class Nomination < Base
      # List nominations, optionally filtered by congress.
      #
      # @param congress [Integer, nil] filter to a specific Congress
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, limit: 20, offset: 0)
        path = congress ? "nomination/#{congress}" : 'nomination'
        client.get(path, { limit: limit, offset: offset })
      end

      # Fetch a nomination's full detail record.
      #
      # @param congress [Integer] e.g. 119
      # @param number   [Integer] nomination number
      # @return [CongressGov::Response]
      def get(congress, number)
        client.get("nomination/#{congress}/#{number}")
      end

      # Fetch a specific ordinal for a nomination.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param ordinal  [Integer]
      # @return [CongressGov::Response]
      def get_ordinal(congress, number, ordinal)
        client.get("nomination/#{congress}/#{number}/#{ordinal}")
      end

      # Actions taken on a nomination.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def actions(congress, number, limit: 20, offset: 0)
        client.get("nomination/#{congress}/#{number}/actions",
                   { limit: limit, offset: offset })
      end

      # Committees associated with a nomination.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def committees(congress, number, limit: 20, offset: 0)
        client.get("nomination/#{congress}/#{number}/committees",
                   { limit: limit, offset: offset })
      end

      # Hearings for a nomination.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def hearings(congress, number, limit: 20, offset: 0)
        client.get("nomination/#{congress}/#{number}/hearings",
                   { limit: limit, offset: offset })
      end
    end
  end
end
