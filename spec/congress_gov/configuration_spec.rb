# frozen_string_literal: true

RSpec.describe CongressGov::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it { expect(config.base_url).to eq('https://api.congress.gov/v3/') }
    it { expect(config.timeout).to eq(30) }
    it { expect(config.retries).to eq(3) }
    it { expect(config.logger).to be_nil }

    it 'reads api_key from ENV' do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('CONGRESS_GOV_API_KEY', nil).and_return('from_env')
      cfg = described_class.new
      expect(cfg.api_key).to eq('from_env')
    end
  end

  describe '#validate!' do
    it 'raises ConfigurationError when api_key is nil' do
      config.api_key = nil
      expect { config.validate! }.to raise_error(CongressGov::ConfigurationError)
    end

    it 'raises ConfigurationError when api_key is empty' do
      config.api_key = ''
      expect { config.validate! }.to raise_error(CongressGov::ConfigurationError)
    end

    it 'does not raise when api_key is present' do
      config.api_key = 'valid_key'
      expect { config.validate! }.not_to raise_error
    end
  end

  describe 'configure block' do
    before do
      CongressGov.configure do |c|
        c.api_key = 'test_key'
        c.timeout = 60
      end
    end

    it 'applies settings' do
      expect(CongressGov.configuration.api_key).to eq('test_key')
      expect(CongressGov.configuration.timeout).to eq(60)
    end
  end
end
