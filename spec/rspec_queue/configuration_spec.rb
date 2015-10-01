require 'rspec_queue/configuration'

describe RSpecQueue::Configuration do
  let(:configuration) { RSpecQueue::Configuration.send(:new) }

  before do
    allow(configuration).to receive(:cpu_count).and_return(8)
  end

  describe "#worker_count" do
    context "default" do
      it "returns the total number of cpus minus 1" do
        expect(configuration.worker_count).to eq 7
      end
    end

    context "RSPEC_QUEUE_WORKERS env var set" do
      before { stub_const("ENV", {"RSPEC_QUEUE_WORKERS" => "5"}) }

      it "returns the given number of workers" do
        expect(configuration.worker_count).to eq 5
      end
    end
  end
end
