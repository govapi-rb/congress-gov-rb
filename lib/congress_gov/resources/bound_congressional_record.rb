# frozen_string_literal: true

module CongressGov
  module Resources
    # Access bound Congressional Record data from the Congress.gov API.
    class BoundCongressionalRecord < Base
      # List bound congressional record years.
      #
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list(limit: 20, offset: 0)
        client.get('bound-congressional-record', { limit: limit, offset: offset })
      end

      # List bound records for a specific year.
      #
      # @param year   [Integer]
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list_by_year(year, limit: 20, offset: 0)
        client.get("bound-congressional-record/#{year}", { limit: limit, offset: offset })
      end

      # List bound records for a specific year and month.
      #
      # @param year   [Integer]
      # @param month  [Integer]
      # @param limit  [Integer]
      # @param offset [Integer]
      # @return [CongressGov::Response]
      def list_by_month(year, month, limit: 20, offset: 0)
        client.get("bound-congressional-record/#{year}/#{month}", { limit: limit, offset: offset })
      end

      # Get bound congressional record for a specific date.
      #
      # @param year  [Integer]
      # @param month [Integer]
      # @param day   [Integer]
      # @return [CongressGov::Response]
      def get(year, month, day)
        client.get("bound-congressional-record/#{year}/#{month}/#{day}")
      end
    end
  end
end
