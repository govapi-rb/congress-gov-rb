# frozen_string_literal: true

require_relative "lib/congress_gov/version"

Gem::Specification.new do |spec|
  spec.name    = "congress_gov"
  spec.version = CongressGov::VERSION
  spec.authors = ["ThePublicTab"]
  spec.email   = ["dev@thepublictab.com"]

  spec.summary = "Ruby client for the Congress.gov API v3"
  spec.description = <<~DESC
    A Ruby client for the Congress.gov REST API v3. Access member data,
    roll call votes, bill details, committee information, and more.
    Includes a fallback parser for Clerk of the House XML vote records.
    The first Ruby client targeting the current v3 API.
  DESC
  spec.homepage = "https://github.com/xjackk/congress-gov-rb"
  spec.license  = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata = {
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => spec.homepage,
    "changelog_uri"         => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri"       => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.files         = Dir.glob("{lib}/**/*") + %w[LICENSE.txt README.md CHANGELOG.md]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday",       "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
  spec.add_dependency "nokogiri",      "~> 1.16"
  spec.add_dependency "faraday-http-cache", "~> 2.0"

  spec.add_development_dependency "rspec",        "~> 3.13"
  spec.add_development_dependency "vcr",          "~> 6.2"
  spec.add_development_dependency "webmock",      "~> 3.23"
  spec.add_development_dependency "rubocop",      "~> 1.65"
  spec.add_development_dependency "rubocop-rspec","~> 3.0"
  spec.add_development_dependency "simplecov",    "~> 0.22"
  spec.add_development_dependency "dotenv",       "~> 3.0"
end
