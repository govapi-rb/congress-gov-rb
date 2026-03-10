#!/usr/bin/env ruby
# frozen_string_literal: true

# Clerk of the House XML parsing — NO API KEY NEEDED.
# This example works without any authentication.
#
# Fetches roll call 281 (HR 5371, Continuing Appropriations Act 2026)
# directly from clerk.house.gov and parses it.
#
# Usage: ruby examples/05_clerk_xml_only.rb

require_relative '../lib/congress_gov'

# Clerk XML doesn't need an API key, but the client requires one.
# Use a dummy key since we're only hitting clerk.house.gov.
CongressGov.configure do |c|
  c.api_key = 'not_needed_for_clerk_xml'
end

puts '=== Clerk of the House XML Parser (No API Key Needed) ==='
puts

puts 'Fetching Roll Call 281 from clerk.house.gov...'
vote = CongressGov.clerk_vote.fetch(year: 2025, roll_call: 281)

puts
puts "Congress:    #{vote[:congress]}th, #{vote[:session]} Session"
puts "Roll Call:   #{vote[:roll_call]}"
puts "Bill:        #{vote[:bill]}"
puts "Question:    #{vote[:question]}"
puts "Description: #{vote[:description]}"
puts "Result:      #{vote[:result]}"
puts "Date:        #{vote[:date]}"
puts
puts 'Vote Totals:'
puts "  Yea:        #{vote[:totals][:yea]}"
puts "  Nay:        #{vote[:totals][:nay]}"
puts "  Present:    #{vote[:totals][:present]}"
puts "  Not Voting: #{vote[:totals][:not_voting]}"
puts
puts 'By Party:'
vote[:totals][:by_party].each do |party, counts|
  printf "  %-12s Yea: %3d  Nay: %3d  Present: %d  Not Voting: %d\n",
         party, counts[:yea], counts[:nay], counts[:present], counts[:not_voting]
end
puts
puts "Total members in vote data: #{vote[:members].size}"
puts

# Show a sample of members
puts 'Sample members:'
puts '-' * 70
printf "%-10s %-20s %-6s %-6s %s\n", 'Bioguide', 'Name', 'Party', 'State', 'Vote'
puts '-' * 70
sample_ids = %w[B001292 A000055 P000197 S001223 J000302]
sample_ids.each do |bioguide|
  m = vote[:members][bioguide]
  printf "%-10s %-20s %-6s %-6s %s\n", bioguide, m[:name], m[:party], m[:state], m[:vote] if m
end
puts '-' * 70
puts
puts '=== Done ==='
