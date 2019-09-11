# frozen_string_literal: true

RSpec.describe Mihari::Analyzers::SecurityTrailsDomainFeed do
  subject { described_class.new(regexp, tags: tags) }

  let(:tags) { %w(test) }
  let(:regexp) { "test" }
  let(:mock) { double("ST API") }
  let(:domains) { %w(test.example.com example.com) }

  describe "#artifacts" do
    before do
      allow(SecurityTrails::API).to receive(:new).and_return(mock)
      allow(mock).to receive_message_chain(:feeds, :domains).and_return(domains)
    end

    it do
      expect(subject.artifacts).to be_an(Array)
    end
  end
end
