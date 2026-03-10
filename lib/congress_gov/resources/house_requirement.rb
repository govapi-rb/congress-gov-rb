# frozen_string_literal: true

module CongressGov
  module Resources
    # Access House requirement data from the Congress.gov API.
    class HouseRequirement < Base
      # List house requirements.
      #
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list(limit: 20, offset: 0)
        client.get('house-requirement', { limit: limit, offset: offset })
      end

      # Fetch a specific house requirement.
      #
      # @param number [Integer]
      # @return [CongressGov::Response]
      def get(number)
        client.get("house-requirement/#{number}")
      end

      # Matching communications for a house requirement.
      #
      # @param number [Integer]
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def matching_communications(number, limit: 20, offset: 0)
        client.get("house-requirement/#{number}/matching-communications",
                   { limit: limit, offset: offset })
      end
    end
  end
end
