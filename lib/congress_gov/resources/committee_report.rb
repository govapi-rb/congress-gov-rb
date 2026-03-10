# frozen_string_literal: true

module CongressGov
  module Resources
    # Access committee report data from the Congress.gov API.
    class CommitteeReport < Base
      # Valid report type codes: hrpt (House), srpt (Senate), erpt (Executive).
      REPORT_TYPES = %w[hrpt srpt erpt].freeze

      # List committee reports, optionally filtered by congress and report type.
      #
      # @param congress    [Integer] filter to a specific Congress
      # @param report_type [String]  one of REPORT_TYPES
      # @param limit       [Integer]
      # @param offset      [Integer]
      # @return [CongressGov::Response]
      def list(congress: nil, report_type: nil, limit: 20, offset: 0)
        params = { limit: limit, offset: offset }

        if congress && report_type
          validate_report_type!(report_type)
          client.get("committee-report/#{congress}/#{report_type.downcase}", params)
        elsif congress
          client.get("committee-report/#{congress}", params)
        else
          client.get('committee-report', params)
        end
      end

      # Fetch a specific committee report.
      #
      # @param congress    [Integer]
      # @param report_type [String]
      # @param number      [Integer]
      # @return [CongressGov::Response]
      def get(congress, report_type, number)
        validate_report_type!(report_type)
        client.get("committee-report/#{congress}/#{report_type.downcase}/#{number}")
      end

      # Text versions of a committee report.
      #
      # @param congress    [Integer]
      # @param report_type [String]
      # @param number      [Integer]
      # @param limit       [Integer]
      # @param offset      [Integer]
      # @return [CongressGov::Response]
      def text(congress, report_type, number, limit: 20, offset: 0)
        validate_report_type!(report_type)
        client.get("committee-report/#{congress}/#{report_type.downcase}/#{number}/text",
                   { limit: limit, offset: offset })
      end

      private

      def validate_report_type!(report_type)
        return if REPORT_TYPES.include?(report_type.to_s.downcase)

        raise ArgumentError,
              "report type must be one of: #{REPORT_TYPES.join(', ')}"
      end
    end
  end
end
