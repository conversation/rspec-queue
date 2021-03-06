require 'rspec/core'
require 'rspec_queue/configuration'
require 'rspec_queue/server'
require 'rspec_queue/worker'

module RSpecQueue
  class ServerRunner < RSpec::Core::Runner
    def run_specs(example_groups)
      worker_pids = []

      example_group_hash = example_groups.map { |example_group|
        [example_group.id, example_group]
      }.to_h

      # start the server, so we are ready to accept connections from workers
      server = RSpecQueue::Server.new

      RSpecQueue::Configuration.instance.worker_count.times do |i|
        env = {
          "RSPEC_QUEUE_WORKER_ID" => i.to_s,
          "RSPEC_QUEUE_SERVER_ADDRESS" => server.socket_path,
        }

        worker_pids << spawn(env, "rspec-queue-worker", *ARGV)
      end

      reporter = @configuration.reporter

      reporter.report(0) do |report|
        @configuration.with_suite_hooks do
          server.dispatch(example_group_hash, report)

          # Exit status
          if @configuration.world.non_example_failure
            1
          else
            [report.failed_examples.count, 1].min
          end
        end
      end
    ensure
      server.close if server

      worker_pids.each do |pid|
        Process.kill("TERM", pid)
        Process.wait(pid)
      end
    end
  end
end
