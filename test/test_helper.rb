ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    def load_fixtures
      stations = YAML.load_file(File.join(File.dirname(__FILE__), "/fixtures/stations.yml"))
      stations.each_value { |station| Station.create(station) }
    end
  end
end
