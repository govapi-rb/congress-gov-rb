# frozen_string_literal: true

require 'congress_gov/version'
require 'congress_gov/configuration'
require 'congress_gov/error'
require 'congress_gov/response'
require 'congress_gov/client'
require 'congress_gov/resources/base'
require 'congress_gov/resources/member'
require 'congress_gov/resources/bill'
require 'congress_gov/resources/house_vote'
require 'congress_gov/resources/clerk_vote'
require 'congress_gov/resources/committee'
require 'congress_gov/resources/amendment'
require 'congress_gov/resources/nomination'
require 'congress_gov/resources/treaty'
require 'congress_gov/resources/house_communication'
require 'congress_gov/resources/senate_communication'
require 'congress_gov/resources/house_requirement'
require 'congress_gov/resources/law'
require 'congress_gov/resources/congress_info'
require 'congress_gov/resources/summary'
require 'congress_gov/resources/committee_report'
require 'congress_gov/resources/committee_print'
require 'congress_gov/resources/committee_meeting'
require 'congress_gov/resources/hearing'
require 'congress_gov/resources/daily_congressional_record'
require 'congress_gov/resources/bound_congressional_record'
require 'congress_gov/resources/crs_report'

# Ruby client for the Congress.gov REST API v3.
# @see https://api.congress.gov/
module CongressGov
  # Mutex for thread-safe initialization of configuration and client.
  @mutex = Mutex.new

  class << self
    # Returns the current configuration instance.
    # Thread-safe via Mutex.
    #
    # @return [CongressGov::Configuration]
    def configuration
      @mutex.synchronize { @configuration ||= Configuration.new }
    end

    # Yields the configuration instance for modification.
    #
    # @yieldparam config [CongressGov::Configuration]
    # @return [void]
    def configure
      @mutex.synchronize { yield(@configuration ||= Configuration.new) }
    end

    # Resets configuration and client to defaults.
    # Thread-safe via Mutex.
    #
    # @return [void]
    def reset!
      @mutex.synchronize do
        @configuration = Configuration.new
        @client        = nil
      end
    end

    # Returns the shared API client instance.
    # Thread-safe via Mutex.
    #
    # @return [CongressGov::Client]
    def client
      @mutex.synchronize { @client ||= Client.new(@configuration || Configuration.new) }
    end

    # Resource shorthand accessors

    # @return [CongressGov::Resources::Member]
    def member
      Resources::Member.new(client)
    end

    # @return [CongressGov::Resources::Bill]
    def bill
      Resources::Bill.new(client)
    end

    # @return [CongressGov::Resources::HouseVote]
    def house_vote
      Resources::HouseVote.new(client)
    end

    # @return [CongressGov::Resources::ClerkVote]
    def clerk_vote
      Resources::ClerkVote.new(client)
    end

    # @return [CongressGov::Resources::Committee]
    def committee
      Resources::Committee.new(client)
    end

    # @return [CongressGov::Resources::Amendment]
    def amendment
      Resources::Amendment.new(client)
    end

    # @return [CongressGov::Resources::Nomination]
    def nomination
      Resources::Nomination.new(client)
    end

    # @return [CongressGov::Resources::Treaty]
    def treaty
      Resources::Treaty.new(client)
    end

    # @return [CongressGov::Resources::HouseCommunication]
    def house_communication
      Resources::HouseCommunication.new(client)
    end

    # @return [CongressGov::Resources::SenateCommunication]
    def senate_communication
      Resources::SenateCommunication.new(client)
    end

    # @return [CongressGov::Resources::HouseRequirement]
    def house_requirement
      Resources::HouseRequirement.new(client)
    end

    # @return [CongressGov::Resources::Law]
    def law
      Resources::Law.new(client)
    end

    # @return [CongressGov::Resources::CongressInfo]
    def congress_info
      Resources::CongressInfo.new(client)
    end

    # @return [CongressGov::Resources::Summary]
    def summary
      Resources::Summary.new(client)
    end

    # @return [CongressGov::Resources::CommitteeReport]
    def committee_report
      Resources::CommitteeReport.new(client)
    end

    # @return [CongressGov::Resources::CommitteePrint]
    def committee_print
      Resources::CommitteePrint.new(client)
    end

    # @return [CongressGov::Resources::CommitteeMeeting]
    def committee_meeting
      Resources::CommitteeMeeting.new(client)
    end

    # @return [CongressGov::Resources::Hearing]
    def hearing
      Resources::Hearing.new(client)
    end

    # @return [CongressGov::Resources::DailyCongressionalRecord]
    def daily_congressional_record
      Resources::DailyCongressionalRecord.new(client)
    end

    # @return [CongressGov::Resources::BoundCongressionalRecord]
    def bound_congressional_record
      Resources::BoundCongressionalRecord.new(client)
    end

    # @return [CongressGov::Resources::CrsReport]
    def crs_report
      Resources::CrsReport.new(client)
    end
  end
end
