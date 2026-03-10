# frozen_string_literal: true

module CongressGov
  module Resources
    # Access committee meeting data from the Congress.gov API.
    class CommitteeMeeting < Base
      # List committee meetings, optionally filtered by congress and chamber.
      #
      # @param congress [Integer]
      # @param chamber  [String]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, chamber: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && chamber
          client.get("committee-meeting/#{congress}/#{chamber.downcase}", params)
        elsif congress
          client.get("committee-meeting/#{congress}", params)
        else
          client.get('committee-meeting', params)
        end
      end

      # Fetch a specific committee meeting.
      #
      # @param congress [Integer]
      # @param chamber  [String]
      # @param event_id [Integer]
      # @return [CongressGov::Response]
      def get(congress, chamber, event_id)
        client.get("committee-meeting/#{congress}/#{chamber.downcase}/#{event_id}")
      end
    end
  end
end
