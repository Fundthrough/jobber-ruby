require "spec_helper"

describe Jobber::API::User do
  subject { described_class.new(jobber_client) }

  let(:jobber_client) { double(:client, refresh_token: refresh_token) }
  let(:refresh_token) { "384593485" }

  before { allow(subject).to receive(:request) }

  describe "#get" do
    before { subject.get("123") }

    it { expect(subject).to have_received(:request).with(:get, "/users/123") }
  end
end
