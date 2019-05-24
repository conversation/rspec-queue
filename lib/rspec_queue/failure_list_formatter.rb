require 'rspec/core/formatters'

module RSpecQueue
  # Taken from rspec-core 3.9.0.pre FailureListFormatter
  class FailureListFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :example_failed, :dump_profile, :message

    def example_failed(failure)
      output.puts "#{failure.example.location}:#{failure.example.description}"
    end

    # Discard profile and messages
    #
    # These outputs are not really relevant in the context of this failure
    # list formatter.
    def dump_profile(_profile); end
    def message(_message); end
  end
end
