# frozen_string_literal: true

module CongressGov
  module Resources
    # Access daily Congressional Record data from the Congress.gov API.
    class DailyCongressionalRecord < Base
      # List daily congressional record volumes.
      #
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list(limit: 20, offset: 0)
        client.get('daily-congressional-record', { limit: limit, offset: offset })
      end

      # List issues for a specific volume.
      #
      # @param volume [Integer]
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list_by_volume(volume, limit: 20, offset: 0)
        client.get("daily-congressional-record/#{volume}", { limit: limit, offset: offset })
      end

      # Get a specific issue.
      #
      # @param volume [Integer]
      # @param issue  [Integer]
      # @return [CongressGov::Response]
      def get_issue(volume, issue)
        client.get("daily-congressional-record/#{volume}/#{issue}")
      end

      # Articles for a specific issue.
      #
      # @param volume [Integer]
      # @param issue  [Integer]
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def articles(volume, issue, limit: 20, offset: 0)
        client.get("daily-congressional-record/#{volume}/#{issue}/articles",
                   { limit: limit, offset: offset })
      end
    end
  end
end
