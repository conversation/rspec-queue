module RSpecQueue
  class Sort
    def self.by_execution_time(examples)
      file_execution_times = Hash.new

      example_status = load_example_status.each do |example, duration|
        existing_duration = file_execution_times[example] || 0.0
        file_execution_times[example] = existing_duration + duration
      end

      # sort so longer running files are first
      examples.sort { |a, b|
        (file_execution_times[b[0]] || Float::INFINITY) <=> (file_execution_times[a[0]] || Float::INFINITY)
      }.to_h
    end

    def self.load_example_status
      return [] unless File.exist?("./.examples")

      File.read("./.examples").split("\n").map { |line|
        result = line.match(/(.+)\[.+\|(.+)seconds/)

        if result
          example = result[1] + "[1]" # programming
          duration = result[2].strip.to_f

          [example, duration]
        else
          nil
        end
      }.compact
    end
  end
end
