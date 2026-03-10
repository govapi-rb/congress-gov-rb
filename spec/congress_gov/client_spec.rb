# frozen_string_literal: true

RSpec.describe CongressGov::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'validates configuration' do
      CongressGov.reset!
      CongressGov.configure { |c| c.api_key = nil }
      expect { described_class.new }.to raise_error(CongressGov::ConfigurationError)
    end
  end

  describe '#connection' do
    it 'returns a Faraday connection' do
      expect(client.connection).to be_a(Faraday::Connection)
    end

    it 'uses the configured base_url' do
      expect(client.connection.url_prefix.to_s).to eq('https://api.congress.gov/v3/')
    end
  end

  describe '#clerk_connection' do
    it 'returns a Faraday connection for clerk.house.gov' do
      expect(client.clerk_connection).to be_a(Faraday::Connection)
      expect(client.clerk_connection.url_prefix.to_s).to eq('https://clerk.house.gov/evs/')
    end
  end

  describe '#get' do
    it 'raises ConnectionError on timeout' do
      stub_request(:get, /api\.congress\.gov/).to_timeout
      expect { client.get('member') }.to raise_error(CongressGov::ConnectionError)
    end

    it 'raises AuthenticationError on 403' do
      stub_request(:get, /api\.congress\.gov/)
        .to_return(status: 403, body: '{"error":"forbidden"}', headers: { 'Content-Type' => 'application/json' })
      expect { client.get('member') }.to raise_error(CongressGov::AuthenticationError)
    end

    it 'raises NotFoundError on 404' do
      stub_request(:get, /api\.congress\.gov/)
        .to_return(status: 404, body: '{"error":"not found"}', headers: { 'Content-Type' => 'application/json' })
      expect { client.get('member/Z999999') }.to raise_error(CongressGov::NotFoundError)
    end

    it 'raises ServerError on 500' do
      stub_request(:get, /api\.congress\.gov/)
        .to_return(status: 500, body: '{"error":"internal"}', headers: { 'Content-Type' => 'application/json' })
      expect { client.get('member') }.to raise_error(CongressGov::ServerError)
    end

    it 'returns a Response on success' do
      stub_request(:get, /api\.congress\.gov/)
        .to_return(status: 200, body: '{"members":[]}', headers: { 'Content-Type' => 'application/json' })
      response = client.get('member')
      expect(response).to be_a(CongressGov::Response)
      expect(response.status).to eq(200)
    end
  end

  describe '#get_clerk_xml' do
    it 'returns raw XML body on success' do
      stub_request(:get, 'https://clerk.house.gov/evs/2025/roll281.xml')
        .to_return(status: 200, body: '<rollcall-vote/>')
      result = client.get_clerk_xml('2025/roll281.xml')
      expect(result).to eq('<rollcall-vote/>')
    end

    it 'returns nil on non-200 status' do
      stub_request(:get, 'https://clerk.house.gov/evs/2025/roll999.xml')
        .to_return(status: 404, body: 'Not Found')
      result = client.get_clerk_xml('2025/roll999.xml')
      expect(result).to be_nil
    end

    it 'returns nil on connection error' do
      stub_request(:get, 'https://clerk.house.gov/evs/2025/roll281.xml').to_timeout
      result = client.get_clerk_xml('2025/roll281.xml')
      expect(result).to be_nil
    end
  end
end
