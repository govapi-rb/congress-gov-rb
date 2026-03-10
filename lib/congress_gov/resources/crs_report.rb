# frozen_string_literal: true

module CongressGov
  module Resources
    # Access Congressional Research Service reports from the Congress.gov API.
    class CrsReport < Base
      # List CRS reports.
      #
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list(limit: 20, offset: 0)
        client.get('crsreport', { limit: limit, offset: offset })
      end
    end
  end
end
