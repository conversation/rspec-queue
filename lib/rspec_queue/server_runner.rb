require 'rspec/core'
require 'rspec_queue/configuration'
require 'rspec_queue/server'
require 'rspec_queue/worker'

module RSpecQueue
  class ServerRunner < RSpec::Core::Runner
    def run_specs(example_groups)
      example_group_hash = example_groups.map { |example_group|
        [example_group.id, example_group]
      }.to_h

      # start the server, so we are ready to accept connections from workers
      server = RSpecQueue::Server.new

      RSpecQueue::Configuration.call_before_fork_hooks
      RSpecQueue::Configuration.instance.worker_count.times do |i|
        env = {
          "RSPEC_QUEUE_WORKER_ID" => i.to_s,
          "RSPEC_QUEUE_SERVER_ADDRESS" => server.socket_path,
        }

        # TODO, store pids so we can clean up after ourselves
        spawn(env, "bundle", "exec", "rspec-queue-worker", *ARGV)
      end

      reporter = @configuration.reporter

      reporter.report(0) do |report|
        server.dispatch(example_group_hash, report)
        [report.failed_examples.count, 1].min # exit status
      end
    ensure
      server.close
    end
  end
end
