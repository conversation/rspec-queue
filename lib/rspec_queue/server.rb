require 'socket'
require 'securerandom'

module RSpecQueue
  class Server

    def initialize
      @server = UNIXServer.open(socket_path)
    end

    def dispatch(example_group_hash, report)
      example_group_keys = example_group_hash.keys

      while (example_group_keys.count > 0 || worker_uuids.count > 0) do
        begin
          socket = @server.accept
          message = socket.gets.to_s.strip

          case message
          when "REGISTER"
            worker_uid = generate_worker_uid
            register_worker(worker_uid)
            socket.puts worker_uid

          when "GET_WORK"
            if example_group_keys.count > 0
              socket.puts example_group_keys.shift
            else
              socket.puts "SHUT_DOWN"
            end

          when "FINISH"
            socket.puts "GET_UUID"
            uuid = socket.gets.to_s.strip

            worker_uuids.delete(uuid)

            socket.puts "GET_RESULTS"
            results = socket.gets.to_s.strip

            json_results = JSON.parse(results, symbolize_names: true)

            examples = json_results.select { |e| e[:status] == "passed" }
            failed_examples = json_results.select { |e| e[:status] == "failed" }
            pending_examples = json_results.select { |e| e[:status] == "pending" }

            report.examples.push(*examples)
            report.failed_examples.push(*failed_examples)
            report.pending_examples.push(*pending_examples)

          else
            puts("unsupported: #{message}")
          end
        ensure
          socket.close
        end
      end
    end

    def close
      @server.close
      FileUtils.rm socket_path
    end

    def register_worker(uid)
      worker_uuids << uid
    end

    def worker_uuids
      @worker_uuids ||= []
    end

    def socket_path
      "/tmp/rspec-queue-server-#{Process.pid}.sock"
    end

    private

    def generate_worker_uid
      @uid_index ||= 0
      "#{SecureRandom.uuid}/#{Process.pid}/worker/#{@uid_index += 1}"
    end
  end
end
