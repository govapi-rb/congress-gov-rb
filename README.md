# congress_gov

Ruby client for the [Congress.gov REST API v3](https://api.congress.gov/). Access member data, roll call votes, bill details, committee information, and more. Includes a fallback parser for Clerk of the House XML vote records.

The first Ruby client targeting the current v3 API.

## Installation

```ruby
gem "congress_gov"
```

Then `bundle install`, or install directly:

```
gem install congress_gov
```

## Configuration

Get an API key at https://api.congress.gov/sign-up/

```ruby
CongressGov.configure do |config|
  config.api_key = ENV["CONGRESS_GOV_API_KEY"]
  config.timeout = 30       # optional, default 30s
  config.retries = 3        # optional, default 3 (handles 429s with exponential backoff)
  config.logger  = Logger.new($stdout)  # optional
end
```

## Usage

### Member Lookup

```ruby
# Get the current rep for a congressional district
rep = CongressGov.member.current_for_district(state: "VA", district: 8)
rep["bioguideId"]  #=> "B001292"

# Full member profile
profile = CongressGov.member.get("B001292")
profile["member"]["directOrderName"]  #=> "Donald S. Beyer"

# Sponsored legislation
CongressGov.member.sponsored_legislation("B001292", limit: 50)

# List all current members (paginated, max 250 per page)
CongressGov.member.list(current: true, limit: 250)
```

### Roll Call Votes

```ruby
# How did a member vote on a specific roll call?
position = CongressGov.house_vote.position_for_member(
  congress: 119, session: 1, roll_call: 281, bioguide_id: "B001292"
)
position  #=> "Nay"

# All member votes as a hash keyed by bioguide ID
votes = CongressGov.house_vote.member_votes_by_bioguide(
  congress: 119, session: 1, roll_call: 281
)
# { "B001292" => "Nay", "A000055" => "Aye", ... }
```

### Bills

```ruby
# Bill detail
bill = CongressGov.bill.get(119, "hr", 5371)

# Find House roll call votes associated with a bill
refs = CongressGov.bill.house_vote_references(119, "hr", 5371)
# [{ "rollNumber" => 281, "chamber" => "House", "url" => "https://clerk.house.gov/..." }]

# Actions, subjects, summaries, cosponsors
CongressGov.bill.actions(119, "hr", 5371)
CongressGov.bill.subjects(119, "hr", 5371)
CongressGov.bill.summaries(119, "hr", 5371)
CongressGov.bill.cosponsors(119, "hr", 5371)
```

### Clerk of the House XML (Fallback)

Parse vote records directly from Clerk XML — no API key needed:

```ruby
vote = CongressGov.clerk_vote.fetch(year: 2025, roll_call: 281)
vote[:result]              #=> "Passed"
vote[:totals][:yea]        #=> 217
vote[:members]["B001292"]  #=> { name: "Beyer", party: "D", state: "VA", vote: "Nay" }

# Or from a URL returned by bill actions
vote = CongressGov.clerk_vote.fetch_by_url("https://clerk.house.gov/evs/2025/roll281.xml")
```

### Committees

```ruby
CongressGov.committee.list(chamber: "house")
CongressGov.committee.get("senate", "ssap00")
CongressGov.committee.for_member("B001292")
```

### Error Handling

```ruby
begin
  CongressGov.member.get("Z999999")
rescue CongressGov::NotFoundError
  puts "Member not found"
rescue CongressGov::AuthenticationError
  puts "Check your API key"
rescue CongressGov::RateLimitError
  puts "Rate limited (5,000 req/hour)"
rescue CongressGov::ParseError => e
  puts "Clerk XML parse failed: #{e.message}"
rescue CongressGov::ConnectionError => e
  puts "Network issue: #{e.message}"
end
```

## The Data Chain

This gem enables crossreferencing congressional votes with federal spending:

```
District
  -> CongressGov.member.current_for_district(state:, district:)
     -> bioguide_id
  -> CongressGov.bill.house_vote_references(congress, type, number)
     -> roll_call numbers
  -> CongressGov.house_vote.position_for_member(congress:, session:, roll_call:, bioguide_id:)
     -> "Yea" or "Nay"
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

To record VCR cassettes against the live API:

```bash
export CONGRESS_GOV_API_KEY="your_real_key"
VCR_RECORD=new_episodes bundle exec rspec
```

## License

MIT License. See [LICENSE.txt](LICENSE.txt).
