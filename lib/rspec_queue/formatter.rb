require 'rspec/core/formatters'
require 'rspec_queue/configuration'

# A custom formatter used for our parallel test suite
module RSpecQueue
  class Formatter < RSpec::Core::Formatters::ProgressFormatter
    RSpec::Core::Formatters.register self, :example_failed, :example_pending, :dump_summary, :dump_pending, :dump_failures

    def initialize(output)
      super
      @output = output
      @failed_examples = []
    end

    def example_failed(failure)
      @failed_examples << failure.example
      @output.puts failure.fully_formatted(@failed_examples.size)
    end

    def example_pending(pending)
      @output.puts "\nPending: #{RSpec::Core::Formatters::ConsoleCodes.wrap(pending.example.metadata[:execution_result].pending_message, :yellow)}"
      @output.puts "  #{RSpec::Core::Formatters::ConsoleCodes.wrap(pending.example.metadata[:location], :cyan)}\n"
    end

    def dump_summary(summary)
      colorizer = RSpec::Core::Formatters::ConsoleCodes

      results_output = [
        "Finished in #{summary.formatted_duration}",
        "(files took #{summary.formatted_load_time} to load)",
        "#{summary.colorized_totals_line}"
      ].join("\n")

      slowest_examples = summary.examples.sort_by { |e| e[:run_time] }.reverse[0..4]
      slowest_example_output = formatted_slowest_examples(slowest_examples, summary.duration, colorizer)

      summary_output = [
        results_output,
        "Top 5 slowest examples:",
        slowest_example_output
      ].join("\n")

      @output.puts summary_output
    end

    def dump_failures(_summary)
      # no-op because we already printed failures once
    end

    def dump_pending(_notification)
      # no-op because we already printed failures once
    end

    private

    def formatted_slowest_examples(slowest_examples, total_duration, colorizer)
      slowest_examples.map { |e|
        location = colorizer.wrap(e[:location], colorizer.console_code_for(:yellow))
        impact_on_build = run_time_impact(e[:run_time], total_duration, colorizer)
        example_information = colorizer.wrap("took #{e[:run_time].round(2)}s, impact on build time is", colorizer.console_code_for(:cyan))
        "#{location} #{example_information} #{impact_on_build}"
      }.join("\n")
    end

    def cpu_count
      RSpecQueue::Configuration.instance.worker_count
    end

    def run_time_impact(example_run_time, total_duration, colorizer)
      overall_impact_in_seconds = (example_run_time / cpu_count).round(2)
      percentage_of_run_time = (example_run_time / (total_duration * cpu_count) * 100).round(1)

      if overall_impact_in_seconds == Float::INFINITY
        "negligible"
      else
        colorizer.wrap("#{overall_impact_in_seconds}s (#{percentage_of_run_time}%)", colorizer.console_code_for(:white))
      end
    end
  end
end
