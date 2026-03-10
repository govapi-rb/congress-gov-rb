#!/usr/bin/env ruby
# frozen_string_literal: true

# Full resource tour — hits every major resource type to verify they work.
# This is the integration test that proves all 18 API resource types are wired correctly.
#
# Usage: CONGRESS_GOV_API_KEY=your_key ruby examples/06_full_resource_tour.rb

require 'dotenv/load'
require_relative '../lib/congress_gov'

CongressGov.configure do |c|
  c.api_key = ENV.fetch('CONGRESS_GOV_API_KEY') do
    abort 'Set CONGRESS_GOV_API_KEY to run this example.'
  end
end

passed = 0
failed = 0

def test(name)
  print "  #{name}... "
  result = yield
  puts "OK (#{result})"
  true
rescue CongressGov::Error => e
  puts "FAIL (#{e.class}: #{e.message})"
  false
rescue StandardError => e
  puts "ERROR (#{e.class}: #{e.message})"
  false
end

puts '=== Full Resource Tour ==='
puts

# 1. Congress
puts '-- Congress --'
if test('congress_info.list') do
  r = CongressGov.congress_info.list(limit: 1)
  "#{r.total_count} congresses"
end
  passed += 1
else
  failed += 1
end
if test('congress_info.current') do
  r = CongressGov.congress_info.current
  "#{r['congress']['number']}th"
end
  passed += 1
else
  failed += 1
end
puts

# 2. Member
puts '-- Member --'
if test('member.list') do
  r = CongressGov.member.list(limit: 1)
  "#{r.total_count} members"
end
  passed += 1
else
  failed += 1
end
if test('member.get(B001292)') do
  r = CongressGov.member.get('B001292')
  r['member']['directOrderName']
end
  passed += 1
else
  failed += 1
end
if test('member.by_district(VA, 8)') do
  r = CongressGov.member.by_district(state: 'VA', district: 8)
  "#{r.results.size} result(s)"
end
  passed += 1
else
  failed += 1
end
if test('member.by_state(VA)') do
  r = CongressGov.member.by_state(state: 'VA', limit: 1)
  "#{r.total_count} members"
end
  passed += 1
else
  failed += 1
end
puts

# 3. Bill
puts '-- Bill --'
if test('bill.list') do
  r = CongressGov.bill.list(limit: 1)
  "#{r.total_count} bills"
end
  passed += 1
else
  failed += 1
end
if test('bill.get(119, hr, 5371)') do
  r = CongressGov.bill.get(119, 'hr', 5371)
  r['bill']['title'].slice(0, 50)
end
  passed += 1
else
  failed += 1
end
if test('bill.actions') do
  r = CongressGov.bill.actions(119, 'hr', 5371, limit: 1)
  "#{r.total_count} actions"
end
  passed += 1
else
  failed += 1
end
if test('bill.subjects') do
  CongressGov.bill.subjects(119, 'hr', 5371)
  'OK'
end
  passed += 1
else
  failed += 1
end
if test('bill.summaries') do
  CongressGov.bill.summaries(119, 'hr', 5371)
  'OK'
end
  passed += 1
else
  failed += 1
end
if test('bill.text') do
  CongressGov.bill.text(119, 'hr', 5371, limit: 1)
  'OK'
end
  passed += 1
else
  failed += 1
end
if test('bill.titles') do
  CongressGov.bill.titles(119, 'hr', 5371, limit: 1)
  'OK'
end
  passed += 1
else
  failed += 1
end
puts

# 4. Amendment
puts '-- Amendment --'
if test('amendment.list') do
  r = CongressGov.amendment.list(limit: 1)
  "#{r.total_count} amendments"
end
  passed += 1
else
  failed += 1
end
puts

# 5. Law
puts '-- Law --'
if test('law.list(118)') do
  r = CongressGov.law.list(118, limit: 1)
  "#{r.total_count} laws"
end
  passed += 1
else
  failed += 1
end
puts

# 6. Summaries (top-level)
puts '-- Summaries --'
if test('summary.list') do
  r = CongressGov.summary.list(limit: 1)
  "#{r.total_count} summaries"
end
  passed += 1
else
  failed += 1
end
puts

# 7. Committee
puts '-- Committee --'
if test('committee.list') do
  r = CongressGov.committee.list(limit: 1)
  "#{r.total_count} committees"
end
  passed += 1
else
  failed += 1
end
puts

# 8. Committee Report
puts '-- Committee Report --'
if test('committee_report.list') do
  r = CongressGov.committee_report.list(limit: 1)
  "#{r.total_count} reports"
end
  passed += 1
else
  failed += 1
end
puts

# 9. Committee Print
puts '-- Committee Print --'
if test('committee_print.list') do
  r = CongressGov.committee_print.list(limit: 1)
  "#{r.total_count} prints"
end
  passed += 1
else
  failed += 1
end
puts

# 10. Committee Meeting
puts '-- Committee Meeting --'
if test('committee_meeting.list') do
  r = CongressGov.committee_meeting.list(limit: 1)
  "#{r.total_count} meetings"
end
  passed += 1
else
  failed += 1
end
puts

# 11. Hearing
puts '-- Hearing --'
if test('hearing.list') do
  r = CongressGov.hearing.list(limit: 1)
  "#{r.total_count} hearings"
end
  passed += 1
else
  failed += 1
end
puts

# 12. House Vote
puts '-- House Vote --'
if test('house_vote.list(119, 1)') do
  r = CongressGov.house_vote.list(congress: 119, session: 1, limit: 1)
  "#{r.total_count} votes"
end
  passed += 1
else
  failed += 1
end
puts

# 13. Nomination
puts '-- Nomination --'
if test('nomination.list') do
  r = CongressGov.nomination.list(limit: 1)
  "#{r.total_count} nominations"
end
  passed += 1
else
  failed += 1
end
puts

# 14. Treaty
puts '-- Treaty --'
if test('treaty.list') do
  r = CongressGov.treaty.list(limit: 1)
  "#{r.total_count} treaties"
end
  passed += 1
else
  failed += 1
end
puts

# 15. House Communication
puts '-- House Communication --'
if test('house_communication.list') do
  r = CongressGov.house_communication.list(limit: 1)
  "#{r.total_count} communications"
end
  passed += 1
else
  failed += 1
end
puts

# 16. Senate Communication
puts '-- Senate Communication --'
if test('senate_communication.list') do
  r = CongressGov.senate_communication.list(limit: 1)
  "#{r.total_count} communications"
end
  passed += 1
else
  failed += 1
end
puts

# 17. House Requirement
puts '-- House Requirement --'
if test('house_requirement.list') do
  r = CongressGov.house_requirement.list(limit: 1)
  "#{r.total_count} requirements"
end
  passed += 1
else
  failed += 1
end
puts

# 18. Daily Congressional Record
puts '-- Daily Congressional Record --'
if test('daily_congressional_record.list') do
  r = CongressGov.daily_congressional_record.list(limit: 1)
  "#{r.total_count} records"
end
  passed += 1
else
  failed += 1
end
puts

# 19. Bound Congressional Record
puts '-- Bound Congressional Record --'
if test('bound_congressional_record.list') do
  r = CongressGov.bound_congressional_record.list(limit: 1)
  "#{r.total_count} records"
end
  passed += 1
else
  failed += 1
end
puts

# 20. CRS Reports
puts '-- CRS Reports --'
if test('crs_report.list') do
  r = CongressGov.crs_report.list(limit: 1)
  "#{r.total_count} reports"
end
  passed += 1
else
  failed += 1
end
puts

puts '=' * 50
puts "Results: #{passed} passed, #{failed} failed out of #{passed + failed}"
puts '=' * 50
