require "test_helper"

class ConnectorTest < ActiveSupport::TestCase
  setup do
    load_fixtures
    station = Station.find_by(name: "ELECTAR_PARIS_15")
    @charger = station.chargers[0]
    @connector = @charger.connectors[0]
  end

  teardown do
    Station.delete_all
  end

  test "available? should return true when there is no session" do
    result = @connector.available?

    assert_equal(true, result)
  end

  test "available? should return false when there is a session" do
    Session.create(connector: @connector)
    
    result = @connector.available?

    assert_equal(false, result)
  end
end
