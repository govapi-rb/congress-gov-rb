# frozen_string_literal: true

require 'nokogiri'
require 'date'

module CongressGov
  module Resources
    # Parse Clerk of the House XML vote records as a fallback to the Congress.gov API.
    class ClerkVote < Base
      # Fetch and parse a roll call vote by year and roll call number.
      #
      # @param year      [Integer] calendar year of the vote
      # @param roll_call [Integer] roll call number (padded to 3 digits in URL)
      # @return [Hash] parsed vote data, or raises ParseError
      def fetch(year:, roll_call:)
        path = "#{year}/roll#{roll_call.to_s.rjust(3, '0')}.xml"
        xml  = client.get_clerk_xml(path)

        raise ParseError, "Could not fetch Clerk XML for #{year}/#{roll_call}" if xml.nil?

        parse(xml)
      end

      # Fetch using a full clerk.house.gov URL (from bill actions recordedVotes).
      #
      # @param url [String] e.g. "https://clerk.house.gov/evs/2025/roll281.xml"
      # @return [Hash]
      def fetch_by_url(url)
        path = url.gsub(%r{.*clerk\.house\.gov/evs/}, '')
        xml  = client.get_clerk_xml(path)

        raise ParseError, "Could not fetch Clerk XML from #{url}" if xml.nil?

        parse(xml)
      end

      # Parse a Clerk XML string into a structured Ruby hash.
      #
      # @param xml [String] raw XML content from clerk.house.gov
      # @return [Hash] structured vote data
      def parse(xml)
        doc = Nokogiri::XML(xml, &:strict)

        {
          congress: doc.at_xpath('//congress')&.text&.to_i,
          session: doc.at_xpath('//session')&.text,
          roll_call: doc.at_xpath('//rollcall-num')&.text&.to_i,
          bill: doc.at_xpath('//legis-num')&.text&.strip,
          question: doc.at_xpath('//vote-question')&.text&.strip,
          result: doc.at_xpath('//vote-result')&.text&.strip,
          description: doc.at_xpath('//vote-desc')&.text&.strip,
          date: parse_date(doc.at_xpath('//action-date')&.text),
          totals: parse_totals(doc),
          members: parse_members(doc)
        }
      rescue Nokogiri::XML::SyntaxError => e
        raise ParseError, "Malformed Clerk XML: #{e.message}"
      end

      private

      def parse_date(date_str)
        return nil if date_str.nil? || date_str.empty?

        Date.strptime(date_str.strip, '%d-%b-%Y')
      rescue Date::Error
        nil
      end

      def parse_totals(doc)
        totals_node = doc.at_xpath('//totals-by-vote')
        by_party    = {}

        doc.xpath('//totals-by-party').each do |party_node|
          party = party_node.at_xpath('party')&.text
          next if party.nil? || party.empty?

          by_party[party] = {
            yea: xml_int(party_node, 'yea-total'),
            nay: xml_int(party_node, 'nay-total'),
            present: xml_int(party_node, 'present-total'),
            not_voting: xml_int(party_node, 'not-voting-total')
          }
        end

        {
          yea: xml_int(totals_node, 'yea-total'),
          nay: xml_int(totals_node, 'nay-total'),
          present: xml_int(totals_node, 'present-total'),
          not_voting: xml_int(totals_node, 'not-voting-total'),
          by_party: by_party
        }
      end

      # Safely extract an integer from an XML node's child element.
      # Returns 0 if the node or child is missing (consistent with vote semantics).
      #
      # @param node [Nokogiri::XML::Node, nil]
      # @param xpath [String]
      # @return [Integer]
      def xml_int(node, xpath)
        node&.at_xpath(xpath)&.text.to_i
      end

      def parse_members(doc)
        result = {}
        doc.xpath('//recorded-vote').each do |vote_node|
          legislator = vote_node.at_xpath('legislator')
          next unless legislator

          bioguide = legislator['name-id']
          next if bioguide.nil? || bioguide.empty?

          result[bioguide] = {
            name: legislator.text.strip,
            party: legislator['party'],
            state: legislator['state'],
            vote: vote_node.at_xpath('vote')&.text&.strip
          }
        end
        result
      end
    end
  end
end
