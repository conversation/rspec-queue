require 'singleton'

module RSpecQueue
  class Configuration
    include Singleton

    def worker_count
      @worker_count ||= [env_queue_workers || cpu_count - 1, 1].max
    end

    private

    def env_queue_workers
      ENV['RSPEC_QUEUE_WORKERS'].to_i if ENV['RSPEC_QUEUE_WORKERS']
    end

    def cpu_count
      num_cpus = if `uname`.chomp == "Darwin"
        `/usr/sbin/sysctl -n hw.ncpu`.to_i
      else
        `grep processor /proc/cpuinfo | wc -l`.to_i
      end
    end
  end
end
