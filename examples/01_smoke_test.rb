#!/usr/bin/env ruby
# frozen_string_literal: true

# Smoke test — verifies the gem can connect to the Congress.gov API.
# Usage: CONGRESS_GOV_API_KEY=your_key ruby examples/01_smoke_test.rb

require 'dotenv/load'
require_relative '../lib/congress_gov'

CongressGov.configure do |c|
  c.api_key = ENV.fetch('CONGRESS_GOV_API_KEY') do
    abort 'Set CONGRESS_GOV_API_KEY to run this example. Get one free at https://api.congress.gov/sign-up/'
  end
end

puts '=== Smoke Test ==='
puts

# 1. Basic connectivity — fetch current congress info
puts '1. Fetching current Congress info...'
response = CongressGov.congress_info.current
congress = response['congress']
puts "   Current Congress: #{congress['number']}th (#{congress['name']})"
puts "   Sessions: #{congress['sessions'].map { |s| s['type'] }.join(', ')}"
puts '   ✓ API connectivity confirmed'
puts

# 2. Member lookup
puts '2. Fetching a member by bioguide ID (B001292 = Don Beyer, VA-08)...'
response = CongressGov.member.get('B001292')
member = response['member']
puts "   Name: #{member['directOrderName']}"
puts "   Party: #{member['partyName']}"
puts "   State: #{member['state']}"
puts '   ✓ Member endpoint works'
puts

# 3. Bill lookup
puts '3. Fetching bill HR 5371 (119th Congress)...'
response = CongressGov.bill.get(119, 'hr', 5371)
bill = response['bill']
puts "   Title: #{bill['title']}"
puts "   Sponsor: #{bill.dig('sponsors', 0, 'fullName') || 'N/A'}"
puts '   ✓ Bill endpoint works'
puts

# 4. List recent bills
puts '4. Listing 3 most recent bills...'
response = CongressGov.bill.list(limit: 3)
response.results.each do |b|
  puts "   - #{b['number']}: #{b['title']&.slice(0, 80)}"
end
puts '   ✓ Bill list endpoint works'
puts

puts '=== All smoke tests passed ==='
