require 'rspec_queue/util'

RSpec.describe RSpecQueue::Util do
  describe ".flat_hashify" do
    let(:object_graph) {
      [double(id: 1, children: [
        double(id: 2, children: []),
        double(id: 3, children: [
          double(id: 4, children: []),
          double(id: 5, children: [])
        ])
      ])]
    }

    it "creates a flat hash" do
      expect(RSpecQueue::Util.flat_hashify(object_graph).keys).to eq [2, 4, 5]
    end
  end
end
