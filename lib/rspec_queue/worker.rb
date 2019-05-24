require 'json'
require 'socket'

module RSpecQueue
  class Worker
    def initialize
      @server_socket = ENV["RSPEC_QUEUE_SERVER_ADDRESS"]

      socket = UNIXSocket.open(@server_socket)
      socket.puts "REGISTER"

      @uuid = socket.gets.to_s.strip
    end

    def has_work?
      socket = UNIXSocket.open(@server_socket)
      socket.puts "GET_WORK"
      message = socket.gets.to_s.strip

      if message == "SHUT_DOWN"
        false
      else
        @example_group_key = message
      end
    end

    def current_example
      @example_group_key
    end

    def finish(reporter)
      socket = UNIXSocket.open(@server_socket)
      socket.puts "FINISH"

      message = socket.gets.to_s.strip

      if (message == "GET_UUID")
        socket.puts @uuid
      else
        puts "warn"
      end

      message = socket.gets.to_s.strip

      # serialize the rspec reporter results back to the server
      if (message == "GET_RESULTS")
        results = reporter.examples.map { |e|
          {
            location: e.metadata[:location],
            status: e.metadata[:execution_result].status,
            run_time: e.metadata[:execution_result].run_time
          }
        }

        socket.puts results.to_json
      else
        puts "warn"
      end
    end
  end
end
