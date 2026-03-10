# frozen_string_literal: true

module CongressGov
  module Resources
    # Access treaty data from the Congress.gov API.
    class Treaty < Base
      # List treaties, optionally filtered by congress.
      #
      # @param congress [Integer, nil] filter to a specific Congress
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, limit: 20, offset: 0)
        path = congress ? "treaty/#{congress}" : 'treaty'
        client.get(path, { limit: limit, offset: offset })
      end

      # Fetch a treaty's full detail record.
      #
      # @param congress [Integer] e.g. 119
      # @param number   [Integer] treaty number
      # @return [CongressGov::Response]
      def get(congress, number)
        client.get("treaty/#{congress}/#{number}")
      end

      # Fetch a treaty with a specific suffix.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param suffix   [String]  treaty suffix
      # @return [CongressGov::Response]
      def get_with_suffix(congress, number, suffix)
        client.get("treaty/#{congress}/#{number}/#{suffix}")
      end

      # Actions taken on a treaty.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def actions(congress, number, limit: 20, offset: 0)
        client.get("treaty/#{congress}/#{number}/actions",
                   { limit: limit, offset: offset })
      end

      # Actions for a treaty with a specific suffix.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param suffix   [String]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def actions_with_suffix(congress, number, suffix, limit: 20, offset: 0)
        client.get("treaty/#{congress}/#{number}/#{suffix}/actions",
                   { limit: limit, offset: offset })
      end

      # Committees associated with a treaty.
      #
      # @param congress [Integer]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def committees(congress, number, limit: 20, offset: 0)
        client.get("treaty/#{congress}/#{number}/committees",
                   { limit: limit, offset: offset })
      end
    end
  end
end
