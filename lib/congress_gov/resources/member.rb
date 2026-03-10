# frozen_string_literal: true

module CongressGov
  module Resources
    # Access member data from the Congress.gov API.
    class Member < Base
      # Fetch the current member representing a congressional district.
      #
      # @param state    [String]  two-letter state abbreviation e.g. "VA", "OH"
      # @param district [Integer, String] district number e.g. 8 or "08"
      # @param congress [Integer] congress number e.g. 119 (default: current 119th)
      # @param current  [Boolean] return only current members (default: true)
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def by_district(state:, district:, congress: 119, current: true, limit: 10, offset: 0)
        district_str = district.to_s.rjust(2, '0')
        params = {
          currentMember: current,
          limit: limit,
          offset: offset
        }
        client.get("member/congress/#{congress}/#{state.upcase}/#{district_str}", params)
      end

      # Fetch a member's full profile by bioguide ID.
      #
      # @param bioguide_id [String] e.g. "B001292" (Don Beyer, VA-08)
      # @return [CongressGov::Response]
      def get(bioguide_id)
        client.get("member/#{bioguide_id}")
      end

      # Get a member's sponsored legislation.
      #
      # @param bioguide_id [String]
      # @param limit       [Integer] max 250
      # @param offset      [Integer]
      # @return [CongressGov::Response]
      def sponsored_legislation(bioguide_id, limit: 20, offset: 0)
        client.get("member/#{bioguide_id}/sponsored-legislation",
                   { limit: limit, offset: offset })
      end

      # Get legislation a member has cosponsored.
      #
      # @param bioguide_id [String]
      # @param limit       [Integer]
      # @param offset      [Integer]
      # @return [CongressGov::Response]
      def cosponsored_legislation(bioguide_id, limit: 20, offset: 0)
        client.get("member/#{bioguide_id}/cosponsored-legislation",
                   { limit: limit, offset: offset })
      end

      # List all current members of Congress (House + Senate).
      #
      # @param current [Boolean] only current members (default: true)
      # @param limit   [Integer]
      # @param offset  [Integer]
      # @return [CongressGov::Response]
      def list(current: true, limit: 250, offset: 0)
        client.get('member', { currentMember: current, limit: limit, offset: offset })
      end

      # List members from a specific state.
      #
      # @param state   [String]  two-letter state abbreviation e.g. "VA", "OH"
      # @param current [Boolean] return only current members (default: true)
      # @param limit   [Integer]
      # @param offset  [Integer]
      # @return [CongressGov::Response]
      def by_state(state:, current: true, limit: 250, offset: 0)
        params = {
          currentMember: current,
          limit: limit,
          offset: offset
        }
        client.get("member/#{state.upcase}", params)
      end

      # List members from a specific state and district.
      #
      # Uses GET /v3/member/:stateCode/:district (distinct from
      # #by_district which uses /member/congress/:congress/…).
      #
      # @param state    [String]  two-letter state abbreviation
      # @param district [Integer, String] district number
      # @param current  [Boolean] return only current members (default: true)
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def by_state_district(state:, district:, current: true, limit: 10, offset: 0)
        district_str = district.to_s.rjust(2, '0')
        params = {
          currentMember: current,
          limit: limit,
          offset: offset
        }
        client.get("member/#{state.upcase}/#{district_str}", params)
      end

      # List members for a specific congress.
      #
      # @param congress [Integer] congress number e.g. 119
      # @param current  [Boolean, nil] filter by current status (nil = omit param)
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def by_congress(congress:, current: nil, limit: 250, offset: 0)
        params = {
          limit: limit,
          offset: offset
        }
        params[:currentMember] = current unless current.nil?
        client.get("member/congress/#{congress}", params)
      end

      # Convenience: return all pages of current members, yielding each page.
      #
      # @yield [Array] results from each page
      def all_current
        offset = 0
        limit  = 250
        loop do
          response = list(current: true, limit: limit, offset: offset)
          yield response.results
          break unless response.has_next_page?

          offset += limit
        end
      end

      # Convenience: returns the single current member for a district,
      # or nil if none found.
      #
      # @param state    [String]
      # @param district [Integer, String]
      # @param congress [Integer] defaults to 119th
      # @return [Hash, nil]
      def current_for_district(state:, district:, congress: 119)
        response = by_district(state: state, district: district,
                               congress: congress, current: true, limit: 1)
        members  = response.results
        return nil if members.empty?

        members.first
      end
    end
  end
end
