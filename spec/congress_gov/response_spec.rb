# frozen_string_literal: true

RSpec.describe CongressGov::Response do
  describe '#results' do
    it 'returns the first array value from the body' do
      body = { 'members' => [{ 'id' => 1 }], 'pagination' => {} }
      response = described_class.new(body, 200)
      expect(response.results).to eq([{ 'id' => 1 }])
    end

    it 'returns an empty array when no array value exists' do
      body = { 'member' => { 'id' => 1 } }
      response = described_class.new(body, 200)
      expect(response.results).to eq([])
    end

    it 'returns the raw body if it is already an Array' do
      body = [{ 'id' => 1 }]
      response = described_class.new(body, 200)
      expect(response.results).to eq([{ 'id' => 1 }])
    end
  end

  describe 'pagination' do
    let(:body) do
      {
        'members' => [{ 'id' => 1 }],
        'pagination' => {
          'count' => 100,
          'next' => 'https://api.congress.gov/v3/member?offset=20&limit=20',
          'prev' => nil
        }
      }
    end
    let(:response) { described_class.new(body, 200) }

    it '#total_count returns the total count' do
      expect(response.total_count).to eq(100)
    end

    it '#next_url returns the next page URL' do
      expect(response.next_url).to include('offset=20')
    end

    it '#prev_url returns nil on first page' do
      expect(response.prev_url).to be_nil
    end

    it '#has_next_page? returns true when next exists' do
      expect(response.has_next_page?).to be true
    end

    it '#next_offset parses offset from next_url' do
      expect(response.next_offset).to eq(20)
    end
  end

  describe '#[]' do
    it 'provides hash-like access to the raw body' do
      response = described_class.new({ 'bill' => { 'title' => 'Test' } }, 200)
      expect(response['bill']['title']).to eq('Test')
    end
  end

  describe '#to_h' do
    it 'returns the raw body' do
      body = { 'test' => true }
      response = described_class.new(body, 200)
      expect(response.to_h).to eq(body)
    end
  end
end
