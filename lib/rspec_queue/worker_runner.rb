require 'rspec/core'
require 'rspec_queue/configuration'
require 'rspec_queue/worker'

module RSpecQueue
  class WorkerRunner < RSpec::Core::Runner
    def run_specs(example_groups)
      example_group_hash = example_groups.map { |example_group|
        [example_group.id, example_group]
      }.to_h

      RSpecQueue::Configuration.instance.server_socket = ENV["RSPEC_QUEUE_SERVER_ADDRESS"]
      RSpecQueue::Configuration.call_after_fork_hooks(ENV["RSPEC_QUEUE_WORKER_ID"])

      worker = RSpecQueue::Worker.new

      reporter = @configuration.reporter

      while(worker.has_work?)
        # can we pass in a custom reporter which instantly reports back
        # to the server?
        example_group_hash[worker.current_example].run(reporter)
      end

        # report the results of the examples run to the master process
      worker.finish(reporter)

    ensure
      Process.exit
    end
  end
end
