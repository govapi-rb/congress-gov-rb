# frozen_string_literal: true

module CongressGov
  module Resources
    # Access bill summary data from the Congress.gov API.
    class Summary < Base
      # List bill summaries with optional congress and bill type filters.
      #
      # @param congress  [Integer, nil] filter to a specific congress
      # @param bill_type [String, nil]  filter to a bill type (e.g. 'hr', 's')
      # @param limit     [Integer]
      # @param offset    [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, bill_type: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && bill_type
          client.get("summaries/#{congress}/#{bill_type.downcase}", params)
        elsif congress
          client.get("summaries/#{congress}", params)
        else
          client.get('summaries', params)
        end
      end
    end
  end
end
