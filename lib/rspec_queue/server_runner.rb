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
      server_socket_path = server.socket_path

      RSpecQueue::Configuration.instance.worker_count.times do |i|
        fork do
          require 'rspec_queue/formatter'
          require 'rspec_queue/failure_list_formatter'

          RSpecQueue::Configuration.instance.server_socket = server_socket_path
          RSpecQueue::Configuration.call_after_worker_spawn_hooks(i.to_s)

          worker = RSpecQueue::Worker.new(server_socket_path)

          @configuration.with_suite_hooks do
            reporter = @configuration.reporter

            while(worker.has_work?)
              # can we pass in a custom reporter which instantly reports back
              # to the server?
              example_group_hash[worker.current_example].run(reporter)
            end

              # report the results of the examples run to the master process
            worker.finish(reporter)
          end
        end
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
      Process.wait
    end
  end
end
