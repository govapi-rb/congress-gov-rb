# frozen_string_literal: true

module CongressGov
  module Resources
    # Access House communication data from the Congress.gov API.
    class HouseCommunication < Base
      # Valid communication type codes: ec (Executive), ml (Memorial), pm (Presidential), pt (Petition).
      COMMUNICATION_TYPES = %w[ec ml pm pt].freeze

      # List house communications.
      #
      # @param congress            [Integer] filter to a specific Congress
      # @param communication_type  [String]  one of COMMUNICATION_TYPES
      # @param limit               [Integer]
      # @param offset              [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, communication_type: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && communication_type
          validate_communication_type!(communication_type)
          client.get("house-communication/#{congress}/#{communication_type.downcase}", params)
        elsif congress
          client.get("house-communication/#{congress}", params)
        else
          client.get('house-communication', params)
        end
      end

      # Fetch a specific house communication.
      #
      # @param congress            [Integer]
      # @param communication_type  [String]
      # @param number              [Integer]
      # @return [CongressGov::Response]
      def get(congress, communication_type, number)
        validate_communication_type!(communication_type)
        client.get("house-communication/#{congress}/#{communication_type.downcase}/#{number}")
      end

      private

      def validate_communication_type!(communication_type)
        return if COMMUNICATION_TYPES.include?(communication_type.to_s.downcase)

        raise ArgumentError,
              "communication type must be one of: #{COMMUNICATION_TYPES.join(', ')}"
      end
    end
  end
end
