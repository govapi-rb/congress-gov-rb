# frozen_string_literal: true

RSpec.describe CongressGov::Resources::ClerkVote do
  subject(:clerk_vote_resource) { CongressGov.clerk_vote }

  let(:roll281_xml) do
    File.read(File.join(__dir__, '../../fixtures/clerk_xml/roll281.xml'))
  end

  describe '#parse' do
    subject(:result) { clerk_vote_resource.parse(roll281_xml) }

    it 'returns a Hash' do
      expect(result).to be_a(Hash)
    end

    it 'parses vote metadata' do
      expect(result[:congress]).to eq(119)
      expect(result[:session]).to eq('1st')
      expect(result[:roll_call]).to eq(281)
      expect(result[:bill]).to eq('H R 5371')
      expect(result[:question]).to eq('On Passage')
      expect(result[:result]).to eq('Passed')
    end

    it 'parses the vote description' do
      expect(result[:description]).to include('Continuing Appropriations')
    end

    it 'parses the date as a Date object' do
      expect(result[:date]).to be_a(Date)
      expect(result[:date].year).to eq(2025)
      expect(result[:date].month).to eq(9)
    end

    it 'parses vote totals' do
      expect(result[:totals][:yea]).to eq(217)
      expect(result[:totals][:nay]).to eq(212)
      expect(result[:totals][:not_voting]).to eq(3)
    end

    it 'includes party breakdown in totals' do
      expect(result[:totals][:by_party]).to include('Republican', 'Democratic')
      expect(result[:totals][:by_party]['Republican'][:yea]).to eq(216)
      expect(result[:totals][:by_party]['Democratic'][:nay]).to eq(210)
    end

    it 'parses all member votes into a hash keyed by bioguide ID' do
      expect(result[:members]).to be_a(Hash)
      expect(result[:members].size).to be > 400
    end

    it 'correctly records Don Beyer (VA-08) as Nay' do
      beyer = result[:members]['B001292']
      expect(beyer).not_to be_nil
      expect(beyer[:vote]).to eq('Nay')
      expect(beyer[:party]).to eq('D')
      expect(beyer[:state]).to eq('VA')
    end

    it 'correctly records Robert Aderholt (R, AL) as Yea' do
      aderholt = result[:members]['A000055']
      expect(aderholt[:vote]).to eq('Yea')
      expect(aderholt[:party]).to eq('R')
    end
  end

  describe '#fetch' do
    it 'fetches and parses a vote by year and roll call number' do
      xml = File.read(File.join(__dir__, '../../fixtures/clerk_xml/roll281.xml'))
      stub_request(:get, 'https://clerk.house.gov/evs/2025/roll281.xml')
        .to_return(status: 200, body: xml)

      result = clerk_vote_resource.fetch(year: 2025, roll_call: 281)
      expect(result[:roll_call]).to eq(281)
      expect(result[:members]).to be_a(Hash)
    end

    it 'raises ParseError when XML cannot be fetched' do
      stub_request(:get, 'https://clerk.house.gov/evs/2025/roll999.xml')
        .to_return(status: 404, body: 'Not Found')

      expect do
        clerk_vote_resource.fetch(year: 2025, roll_call: 999)
      end.to raise_error(CongressGov::ParseError, /Could not fetch/)
    end
  end

  describe '#fetch_by_url' do
    it 'fetches using a full clerk.house.gov URL' do
      xml = File.read(File.join(__dir__, '../../fixtures/clerk_xml/roll281.xml'))
      stub_request(:get, 'https://clerk.house.gov/evs/2025/roll281.xml')
        .to_return(status: 200, body: xml)

      result = clerk_vote_resource.fetch_by_url(
        'https://clerk.house.gov/evs/2025/roll281.xml'
      )
      expect(result[:congress]).to eq(119)
    end
  end

  describe 'error handling' do
    it 'raises ParseError for malformed XML' do
      expect do
        clerk_vote_resource.parse('<broken xml')
      end.to raise_error(CongressGov::ParseError, /Malformed/)
    end
  end
end
