# frozen_string_literal: true

module CongressGov
  module Resources
    # Access committee print data from the Congress.gov API.
    class CommitteePrint < Base
      # List committee prints, optionally filtered by congress and chamber.
      #
      # @param congress [Integer]
      # @param chamber  [String]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, chamber: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && chamber
          client.get("committee-print/#{congress}/#{chamber.downcase}", params)
        elsif congress
          client.get("committee-print/#{congress}", params)
        else
          client.get('committee-print', params)
        end
      end

      # Fetch a specific committee print.
      #
      # @param congress      [Integer]
      # @param chamber       [String]
      # @param jacket_number [Integer]
      # @return [CongressGov::Response]
      def get(congress, chamber, jacket_number)
        client.get("committee-print/#{congress}/#{chamber.downcase}/#{jacket_number}")
      end

      # Text versions of a committee print.
      #
      # @param congress      [Integer]
      # @param chamber       [String]
      # @param jacket_number [Integer]
      # @param limit         [Integer]
      # @param offset        [Integer]
      # @return [CongressGov::Response]
      def text(congress, chamber, jacket_number, limit: 20, offset: 0)
        client.get("committee-print/#{congress}/#{chamber.downcase}/#{jacket_number}/text",
                   { limit: limit, offset: offset })
      end
    end
  end
end
