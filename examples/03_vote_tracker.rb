#!/usr/bin/env ruby
# frozen_string_literal: true

# Real-world scenario: Track how a member voted on recent House roll calls.
# This is the core of ThePublicTab's vote-spending crossref.
#
# Usage: CONGRESS_GOV_API_KEY=your_key ruby examples/03_vote_tracker.rb [BIOGUIDE_ID]
# Example: ruby examples/03_vote_tracker.rb B001292

require 'dotenv/load'
require_relative '../lib/congress_gov'

CongressGov.configure do |c|
  c.api_key = ENV.fetch('CONGRESS_GOV_API_KEY') do
    abort 'Set CONGRESS_GOV_API_KEY to run this example.'
  end
end

bioguide_id = ARGV[0] || 'B001292' # Don Beyer, VA-08

# Step 1: Get member info
puts "=== Vote Tracker for #{bioguide_id} ==="
profile = CongressGov.member.get(bioguide_id)
member = profile['member']
puts "Member: #{member['directOrderName']} (#{member['partyName']}, #{member['state']})"
puts

# Step 2: Get recent House votes (119th Congress, 1st session)
puts 'Fetching recent House roll call votes (119th Congress, Session 1)...'
votes_response = CongressGov.house_vote.list(congress: 119, session: 1, limit: 10)
puts "Total votes this session: #{votes_response.total_count}"
puts

# Step 3: Check how this member voted on each
puts 'Recent votes:'
puts '-' * 90
printf "%-8s %-55s %-10s %s\n", 'Roll', 'Question', 'Result', 'Position'
puts '-' * 90

votes_response.results.each do |vote|
  roll = vote['rollCallNumber']
  question = (vote['voteType'] || 'N/A').slice(0, 55)
  result = vote['result'] || 'N/A'

  # Look up this member's position
  position = CongressGov.house_vote.position_for_member(
    congress: 119,
    session: 1,
    roll_call: roll,
    bioguide_id: bioguide_id
  )

  printf "%-8s %-55s %-10s %s\n", roll, question, result, position || 'N/A'
end

puts '-' * 90
puts
puts '=== Done ==='
