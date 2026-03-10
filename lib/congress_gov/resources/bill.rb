# frozen_string_literal: true

module CongressGov
  module Resources
    # Access bill data from the Congress.gov API.
    class Bill < Base
      # Valid bill type codes: hr, s, hjres, sjres, hconres, sconres, hres, sres.
      BILL_TYPES = %w[hr s hjres sjres hconres sconres hres sres].freeze

      # Fetch a bill's full detail record.
      #
      # @param congress [Integer] e.g. 119
      # @param type     [String]  bill type, one of BILL_TYPES
      # @param number   [Integer] bill number
      # @return [CongressGov::Response]
      def get(congress, type, number)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}")
      end

      # Bill actions — includes roll call vote references.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def actions(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/actions",
                   { limit: limit, offset: offset })
      end

      # Extract only actions that have recorded House votes.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @return [Array<Hash>]
      def house_vote_references(congress, type, number)
        all_actions = []
        offset = 0
        loop do
          response = actions(congress, type, number, limit: 250, offset: offset)
          all_actions.concat(response.results)
          break unless response.has_next_page?

          offset += 250
        end

        all_actions
          .flat_map { |action| action['recordedVotes'] || [] }
          .select { |vote| vote['chamber'] == 'House' }
      end

      # CRS subject terms for a bill.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @return [CongressGov::Response]
      def subjects(congress, type, number)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/subjects")
      end

      # CRS plain-language summaries.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @return [CongressGov::Response]
      def summaries(congress, type, number)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/summaries")
      end

      # Cosponsors list.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def cosponsors(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/cosponsors",
                   { limit: limit, offset: offset })
      end

      # Amendments to a bill.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def amendments(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/amendments",
                   { limit: limit, offset: offset })
      end

      # Committees associated with a bill.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def committees(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/committees",
                   { limit: limit, offset: offset })
      end

      # Related bills.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def related_bills(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/relatedbills",
                   { limit: limit, offset: offset })
      end

      # Full text versions of a bill.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def text(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/text",
                   { limit: limit, offset: offset })
      end

      # Official and short titles for a bill.
      #
      # @param congress [Integer]
      # @param type     [String]
      # @param number   [Integer]
      # @param limit    [Integer]
      # @param offset   [Integer]
      # @return [CongressGov::Response]
      def titles(congress, type, number, limit: 20, offset: 0)
        validate_type!(type)
        client.get("bill/#{congress}/#{type.downcase}/#{number}/titles",
                   { limit: limit, offset: offset })
      end

      # Search / list bills with optional filters.
      #
      # @param congress    [Integer] filter to a specific Congress
      # @param bill_type   [String]  filter to a bill type
      # @param from_date   [String]  "YYYY-MM-DD" — filter by update date
      # @param to_date     [String]  "YYYY-MM-DD"
      # @param sort        [String]  "updateDate+asc" or "updateDate+desc"
      # @param limit       [Integer]
      # @param offset      [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, bill_type: nil, from_date: nil, to_date: nil,
               sort: 'updateDate+desc', limit: 20, offset: 0)
        params = { sort: sort, limit: limit, offset: offset }
        params[:fromDateTime] = "#{from_date}T00:00:00Z" if from_date
        params[:toDateTime]   = "#{to_date}T00:00:00Z"   if to_date

        if congress && bill_type
          validate_type!(bill_type)
          client.get("bill/#{congress}/#{bill_type.downcase}", params)
        elsif congress
          client.get("bill/#{congress}", params)
        else
          client.get('bill', params)
        end
      end

      private

      def validate_type!(type)
        return if BILL_TYPES.include?(type.to_s.downcase)

        raise ArgumentError,
              "bill type must be one of: #{BILL_TYPES.join(', ')}"
      end
    end
  end
end
