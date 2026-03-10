# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Law do
  subject(:law_resource) { CongressGov.law }

  describe '#list' do
    it 'lists laws for a congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/law/119})
        .to_return(status: 200, body: '{"laws":[{"number":"1","type":"pub"}],"pagination":{"count":10}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = law_resource.list(119)
      expect(response).to be_a(CongressGov::Response)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list_by_type' do
    it 'lists public laws for a congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/law/119/pub})
        .to_return(status: 200, body: '{"laws":[{"number":"1","type":"pub"}],"pagination":{"count":5}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = law_resource.list_by_type(119, 'pub')
      expect(response).to be_a(CongressGov::Response)
      expect(response.results).to be_an(Array)
    end

    it 'lists private laws for a congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/law/119/priv})
        .to_return(status: 200, body: '{"laws":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = law_resource.list_by_type(119, 'priv')
      expect(response.results).to eq([])
    end

    it 'raises ArgumentError for invalid law type' do
      expect { law_resource.list_by_type(119, 'invalid') }.to raise_error(ArgumentError, /law type/)
    end
  end

  describe '#get' do
    it 'returns a specific law' do
      stub_request(:get, %r{api\.congress\.gov/v3/law/119/pub/4})
        .to_return(status: 200, body: '{"law":{"number":"4","type":"pub","congress":119}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = law_resource.get(119, 'pub', 4)
      expect(response).to be_a(CongressGov::Response)
      expect(response['law']).to include('number' => '4', 'type' => 'pub')
    end

    it 'raises ArgumentError for invalid law type' do
      expect { law_resource.get(119, 'zz', 1) }.to raise_error(ArgumentError, /law type/)
    end
  end
end
