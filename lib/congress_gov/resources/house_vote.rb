# frozen_string_literal: true

module CongressGov
  module Resources
    # Access House roll call vote data from the Congress.gov API.
    class HouseVote < Base
      # List all House roll call votes (no filters).
      #
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list_all(limit: 20, offset: 0)
        client.get('house-vote', { limit: limit, offset: offset })
      end

      # List House roll call votes for a specific Congress.
      #
      # @param congress [Integer] e.g. 119
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list_by_congress(congress:, limit: 20, offset: 0)
        client.get("house-vote/#{congress}", { limit: limit, offset: offset })
      end

      # List House roll call votes for a Congress and session.
      #
      # @param congress [Integer] e.g. 119
      # @param session  [Integer] 1 or 2
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @param from_date [String] "YYYY-MM-DD"
      # @param to_date   [String] "YYYY-MM-DD"
      # @return [CongressGov::Response]
      def list(congress:, session:, limit: 20, offset: 0,
               from_date: nil, to_date: nil)
        params = { limit: limit, offset: offset }
        params[:startDate] = from_date if from_date
        params[:endDate]   = to_date   if to_date
        client.get("house-vote/#{congress}/#{session}", params)
      end

      # Fetch a single House roll call vote record.
      #
      # @param congress  [Integer]
      # @param session   [Integer]
      # @param roll_call [Integer]
      # @return [CongressGov::Response]
      def get(congress:, session:, roll_call:)
        client.get("house-vote/#{congress}/#{session}/#{roll_call}")
      end

      # Fetch how each member voted on a specific roll call.
      #
      # @param congress  [Integer]
      # @param session   [Integer]
      # @param roll_call [Integer]
      # @param limit     [Integer]
      # @param offset    [Integer]
      # @return [CongressGov::Response]
      def members(congress:, session:, roll_call:, limit: 250, offset: 0)
        client.get("house-vote/#{congress}/#{session}/#{roll_call}/members",
                   { limit: limit, offset: offset })
      end

      # Convenience: return all member votes as a Hash keyed by bioguide ID.
      #
      # The members endpoint nests data under +houseRollCallVoteMemberVotes.results+.
      # The bioguide field is +bioguideID+ (capital D).
      #
      # @param congress  [Integer]
      # @param session   [Integer]
      # @param roll_call [Integer]
      # @return [Hash{String => String}] bioguide_id => voteCast
      def member_votes_by_bioguide(congress:, session:, roll_call:)
        result = {}
        offset = 0
        loop do
          response = members(
            congress: congress,
            session: session,
            roll_call: roll_call,
            limit: 250,
            offset: offset
          )
          member_list = extract_member_votes(response)
          member_list.each do |member|
            bioguide = member['bioguideID'] || member['bioguideId']
            result[bioguide] = member['voteCast']
          end
          break unless response.has_next_page?

          offset += 250
        end
        result
      end

      # Convenience: get the vote position for a single member on a roll call.
      #
      # @param congress    [Integer]
      # @param session     [Integer]
      # @param roll_call   [Integer]
      # @param bioguide_id [String]
      # @return [String, nil] "Aye", "Nay", "Present", "Not Voting", or nil
      def position_for_member(congress:, session:, roll_call:, bioguide_id:)
        member_votes_by_bioguide(
          congress: congress, session: session, roll_call: roll_call
        )[bioguide_id]
      end

      private

      # Extract the member votes array from the nested response structure.
      # The API nests member votes under +houseRollCallVoteMemberVotes.results+.
      # Falls back to +Response#results+ for compatibility with stubbed tests.
      #
      # @param response [CongressGov::Response]
      # @return [Array<Hash>]
      def extract_member_votes(response)
        nested = response.raw.dig('houseRollCallVoteMemberVotes', 'results')
        return nested if nested.is_a?(Array)

        response.results
      end
    end
  end
end
