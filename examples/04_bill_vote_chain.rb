#!/usr/bin/env ruby
# frozen_string_literal: true

# Real-world scenario: The full ThePublicTab data chain.
# Bill -> recorded votes -> member positions -> Clerk XML fallback
#
# Traces HR 5371 (Continuing Appropriations Act, 2026) through the full pipeline:
# 1. Fetch the bill
# 2. Get its recorded vote references
# 3. Look up member positions via the Congress.gov API
# 4. Cross-check against Clerk of the House XML
#
# Usage: CONGRESS_GOV_API_KEY=your_key ruby examples/04_bill_vote_chain.rb

require 'dotenv/load'
require_relative '../lib/congress_gov'

CongressGov.configure do |c|
  c.api_key = ENV.fetch('CONGRESS_GOV_API_KEY') do
    abort 'Set CONGRESS_GOV_API_KEY to run this example.'
  end
end

puts '=== Bill -> Vote -> Member Chain (HR 5371, 119th Congress) ==='
puts

# Step 1: Fetch the bill
puts '1. Fetching bill...'
response = CongressGov.bill.get(119, 'hr', 5371)
bill = response['bill']
puts "   #{bill['number']}: #{bill['title']}"
puts

# Step 2: Get bill actions and extract vote references
puts '2. Extracting House vote references from bill actions...'
refs = CongressGov.bill.house_vote_references(119, 'hr', 5371)
puts "   Found #{refs.size} House roll call vote(s)"
refs.each do |ref|
  puts "   - Roll Call #{ref['rollNumber']} (Session #{ref['sessionNumber']})"
  puts "     Clerk XML: #{ref['url']}"
end
puts

if refs.empty?
  puts '   No recorded House votes found for this bill.'
  puts '   (This can happen if the bill hasn\'t been voted on yet.)'
  exit 0
end

# Step 3: For the first vote, look up specific members via Congress.gov API
ref = refs.first
roll_call = ref['rollNumber']
session = ref['sessionNumber']

puts "3. Looking up member positions for Roll Call #{roll_call} via Congress.gov API..."
spot_check = %w[B001292 A000055 P000197]
spot_check.each do |bioguide|
  position = CongressGov.house_vote.position_for_member(
    congress: 119, session: session, roll_call: roll_call, bioguide_id: bioguide
  )
  puts "   #{bioguide}: #{position || 'Not found'}"
rescue CongressGov::Error => e
  puts "   #{bioguide}: API error (#{e.message})"
end
puts

# Step 4: Clerk XML fallback — parse the same vote from clerk.house.gov
puts '4. Fetching and parsing Clerk of the House XML (no API key needed)...'
begin
  clerk_url = ref['url']
  vote = if clerk_url
           CongressGov.clerk_vote.fetch_by_url(clerk_url)
         else
           # Construct from roll call number
           CongressGov.clerk_vote.fetch(year: 2025, roll_call: roll_call)
         end

  puts "   Bill: #{vote[:bill]}"
  puts "   Question: #{vote[:question]}"
  puts "   Result: #{vote[:result]}"
  puts "   Date: #{vote[:date]}"
  puts "   Totals: Yea #{vote[:totals][:yea]}, Nay #{vote[:totals][:nay]}, " \
       "Not Voting #{vote[:totals][:not_voting]}"
  puts
  puts '   Party breakdown:'
  vote[:totals][:by_party].each do |party, counts|
    puts "   #{party}: Yea #{counts[:yea]}, Nay #{counts[:nay]}"
  end
  puts
  puts '   Spot-check members from Clerk XML:'
  spot_check.each do |bioguide|
    m = vote[:members][bioguide]
    if m
      puts "   #{bioguide} (#{m[:name]}, #{m[:party]}-#{m[:state]}): #{m[:vote]}"
    else
      puts "   #{bioguide}: Not found in Clerk XML"
    end
  end
rescue CongressGov::ParseError => e
  puts "   Clerk XML parse error: #{e.message}"
rescue CongressGov::Error => e
  puts "   Error: #{e.message}"
end

puts
puts '=== Done ==='
