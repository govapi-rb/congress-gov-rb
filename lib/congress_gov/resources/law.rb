# frozen_string_literal: true

module CongressGov
  module Resources
    # Access law data from the Congress.gov API.
    class Law < Base
      # Valid law type codes: pub (public), priv (private).
      LAW_TYPES = %w[pub priv].freeze

      # List laws for a given congress.
      #
      # @param congress [Integer] e.g. 119
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list(congress, limit: 20, offset: 0)
        client.get("law/#{congress}", { limit: limit, offset: offset })
      end

      # List laws for a given congress filtered by type.
      #
      # @param congress [Integer]
      # @param law_type [String] 'pub' or 'priv'
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list_by_type(congress, law_type, limit: 20, offset: 0)
        validate_law_type!(law_type)
        client.get("law/#{congress}/#{law_type.downcase}", { limit: limit, offset: offset })
      end

      # Fetch a specific law.
      #
      # @param congress  [Integer]
      # @param law_type  [String] 'pub' or 'priv'
      # @param number    [Integer]
      # @return [CongressGov::Response]
      def get(congress, law_type, number)
        validate_law_type!(law_type)
        client.get("law/#{congress}/#{law_type.downcase}/#{number}")
      end

      private

      def validate_law_type!(law_type)
        return if LAW_TYPES.include?(law_type.to_s.downcase)

        raise ArgumentError,
              "law type must be one of: #{LAW_TYPES.join(', ')}"
      end
    end
  end
end
