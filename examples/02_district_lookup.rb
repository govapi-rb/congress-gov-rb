#!/usr/bin/env ruby
# frozen_string_literal: true

# Real-world scenario: Look up the current representative for a congressional district.
# This is the primary use case for ThePublicTab.
#
# Usage: CONGRESS_GOV_API_KEY=your_key ruby examples/02_district_lookup.rb [STATE] [DISTRICT]
# Example: ruby examples/02_district_lookup.rb VA 8

require 'dotenv/load'
require_relative '../lib/congress_gov'

CongressGov.configure do |c|
  c.api_key = ENV.fetch('CONGRESS_GOV_API_KEY') do
    abort 'Set CONGRESS_GOV_API_KEY to run this example.'
  end
end

state    = ARGV[0] || 'VA'
district = ARGV[1] || '8'

puts "=== District Lookup: #{state}-#{district} ==="
puts

# Step 1: Find current representative
puts '1. Looking up current representative...'
rep = CongressGov.member.current_for_district(state: state, district: district)

if rep.nil?
  puts "   No current representative found for #{state}-#{district}"
  exit 1
end

bioguide_id = rep['bioguideId']
puts "   Found: #{rep['name']} (#{rep['partyName']})"
puts "   Bioguide ID: #{bioguide_id}"
puts

# Step 2: Get full profile
puts '2. Fetching full profile...'
profile = CongressGov.member.get(bioguide_id)
member = profile['member']
puts "   Full name: #{member['directOrderName']}"
puts "   Born: #{member['birthYear']}"
puts "   Terms served: #{member['terms']&.size || 'N/A'}"
puts

# Step 3: Sponsored legislation
puts '3. Recent sponsored legislation...'
sponsored = CongressGov.member.sponsored_legislation(bioguide_id, limit: 5)
puts "   Total sponsored: #{sponsored.total_count}"
sponsored.results.each do |bill|
  title = bill['title']&.slice(0, 75) || 'Untitled'
  puts "   - #{bill['number']}: #{title}"
end
puts

# Step 4: Cosponsored legislation
puts '4. Recent cosponsored legislation...'
cosponsored = CongressGov.member.cosponsored_legislation(bioguide_id, limit: 5)
puts "   Total cosponsored: #{cosponsored.total_count}"
cosponsored.results.each do |bill|
  title = bill['title']&.slice(0, 75) || 'Untitled'
  puts "   - #{bill['number']}: #{title}"
end
puts

puts '=== Done ==='
