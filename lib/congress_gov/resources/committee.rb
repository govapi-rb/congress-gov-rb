# frozen_string_literal: true

module CongressGov
  module Resources
    # Access committee data from the Congress.gov API.
    class Committee < Base
      # Valid chamber values: house, senate, joint.
      CHAMBERS = %w[house senate joint].freeze

      # List all committees.
      #
      # @param chamber [String] "house", "senate", or "joint" (nil = all)
      # @param congress [Integer] filter to a specific Congress
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list(chamber: nil, congress: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && chamber
          validate_chamber!(chamber)
          client.get("committee/#{congress}/#{chamber.downcase}", params)
        elsif congress
          client.get("committee/#{congress}", params)
        elsif chamber
          validate_chamber!(chamber)
          client.get("committee/#{chamber.downcase}", params)
        else
          client.get('committee', params)
        end
      end

      # Committee detail by chamber and committee code.
      #
      # @param chamber        [String]
      # @param committee_code [String] e.g. "ssap00" for Senate Appropriations
      # @return [CongressGov::Response]
      def get(chamber, committee_code)
        validate_chamber!(chamber)
        client.get("committee/#{chamber.downcase}/#{committee_code.downcase}")
      end

      # Bills referred to a committee.
      #
      # @param chamber        [String]
      # @param committee_code [String]
      # @param limit          [Integer]
      # @param offset         [Integer]
      # @return [CongressGov::Response]
      def bills(chamber, committee_code, limit: 20, offset: 0)
        validate_chamber!(chamber)
        client.get("committee/#{chamber.downcase}/#{committee_code.downcase}/bills",
                   { limit: limit, offset: offset })
      end

      # Committee detail scoped to a specific congress.
      #
      # @param congress        [Integer]
      # @param chamber         [String]
      # @param committee_code  [String]
      # @return [CongressGov::Response]
      def get_by_congress(congress, chamber, committee_code)
        validate_chamber!(chamber)
        client.get("committee/#{congress}/#{chamber.downcase}/#{committee_code.downcase}")
      end

      # Reports for a committee.
      #
      # @param chamber        [String]
      # @param committee_code [String]
      # @param limit          [Integer]
      # @param offset         [Integer]
      # @return [CongressGov::Response]
      def reports(chamber, committee_code, limit: 20, offset: 0)
        validate_chamber!(chamber)
        client.get("committee/#{chamber.downcase}/#{committee_code.downcase}/reports",
                   { limit: limit, offset: offset })
      end

      # Nominations for a committee.
      #
      # @param chamber        [String]
      # @param committee_code [String]
      # @param limit          [Integer]
      # @param offset         [Integer]
      # @return [CongressGov::Response]
      def nominations(chamber, committee_code, limit: 20, offset: 0)
        validate_chamber!(chamber)
        client.get("committee/#{chamber.downcase}/#{committee_code.downcase}/nominations",
                   { limit: limit, offset: offset })
      end

      # House communications for a committee.
      #
      # @param chamber        [String]
      # @param committee_code [String]
      # @param limit          [Integer]
      # @param offset         [Integer]
      # @return [CongressGov::Response]
      def house_communication(chamber, committee_code, limit: 20, offset: 0)
        validate_chamber!(chamber)
        client.get("committee/#{chamber.downcase}/#{committee_code.downcase}/house-communication",
                   { limit: limit, offset: offset })
      end

      # Senate communications for a committee.
      #
      # @param chamber        [String]
      # @param committee_code [String]
      # @param limit          [Integer]
      # @param offset         [Integer]
      # @return [CongressGov::Response]
      def senate_communication(chamber, committee_code, limit: 20, offset: 0)
        validate_chamber!(chamber)
        client.get("committee/#{chamber.downcase}/#{committee_code.downcase}/senate-communication",
                   { limit: limit, offset: offset })
      end

      # Get all committees a member sits on (committee memberships).
      #
      # @param bioguide_id [String]
      # @return [CongressGov::Response]
      def for_member(bioguide_id)
        client.get("committee-membership/#{bioguide_id}")
      end

      private

      def validate_chamber!(chamber)
        return if CHAMBERS.include?(chamber.to_s.downcase)

        raise ArgumentError, "chamber must be one of: #{CHAMBERS.join(', ')}"
      end
    end
  end
end
