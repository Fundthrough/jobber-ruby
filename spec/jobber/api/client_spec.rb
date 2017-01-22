require "spec_helper"

describe Jobber::API::Client do
  subject { described_class.new(jobber_client) }

  let(:jobber_client) { double(:client, refresh_token: refresh_token) }
  let(:refresh_token) { "384593485" }

  before { allow(subject).to receive(:request) }

  describe "#list" do
    before { subject.list(page: 4) }

    it { expect(subject).to have_received(:request).with(:get, "/clients", query: { page: 4 }) }
  end
end
