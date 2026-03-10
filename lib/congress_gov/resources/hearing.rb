# frozen_string_literal: true

module CongressGov
  module Resources
    # Access hearing data from the Congress.gov API.
    class Hearing < Base
      # List hearings, optionally filtered by congress and chamber.
      #
      # @param congress [Integer]
      # @param chamber  [String]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, chamber: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && chamber
          client.get("hearing/#{congress}/#{chamber.downcase}", params)
        elsif congress
          client.get("hearing/#{congress}", params)
        else
          client.get('hearing', params)
        end
      end

      # Fetch a specific hearing.
      #
      # @param congress      [Integer]
      # @param chamber       [String]
      # @param jacket_number [Integer]
      # @return [CongressGov::Response]
      def get(congress, chamber, jacket_number)
        client.get("hearing/#{congress}/#{chamber.downcase}/#{jacket_number}")
      end
    end
  end
end
