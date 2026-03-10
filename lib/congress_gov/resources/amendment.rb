# frozen_string_literal: true

module CongressGov
  module Resources
    # Access amendment data from the Congress.gov API.
    class Amendment < Base
      # Valid amendment type codes: samdt (Senate), hamdt (House), suamdt (Senate unprinted).
      AMENDMENT_TYPES = %w[samdt hamdt suamdt].freeze

      # List amendments with optional congress and type filters.
      #
      # @param congress       [Integer, nil] e.g. 119
      # @param amendment_type [String, nil]  one of AMENDMENT_TYPES
      # @param limit          [Integer]
      # @param offset         [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, amendment_type: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && amendment_type
          validate_type!(amendment_type)
          client.get("amendment/#{congress}/#{amendment_type.downcase}", params)
        elsif congress
          client.get("amendment/#{congress}", params)
        else
          client.get('amendment', params)
        end
      end

      # Fetch a single amendment record.
      #
      # @param congress [Integer]
      # @param type     [String]  one of AMENDMENT_TYPES
      # @param number   [Integer]
      # @return [CongressGov::Response]
      def get(congress, type, number)
        validate_type!(type)
        client.get("amendment/#{congress}/#{type.downcase}/#{number}")
      end

      # Actions taken on an amendment.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def actions(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("amendment/#{congress}/#{type.downcase}/#{number}/actions",
                   { limit: limit, offset: offset })
      end

      # Sub-amendments to an amendment.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def amendments(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("amendment/#{congress}/#{type.downcase}/#{number}/amendments",
                   { limit: limit, offset: offset })
      end

      # Cosponsors of an amendment.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def cosponsors(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("amendment/#{congress}/#{type.downcase}/#{number}/cosponsors",
                   { limit: limit, offset: offset })
      end

      # Text versions of an amendment.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def text(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("amendment/#{congress}/#{type.downcase}/#{number}/text",
                   { limit: limit, offset: offset })
      end

      private

      def validate_type!(type)
        return if AMENDMENT_TYPES.include?(type.to_s.downcase)

        raise ArgumentError,
              "amendment type must be one of: #{AMENDMENT_TYPES.join(', ')}"
      end
    end
  end
end
