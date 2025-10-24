require "test_helper"

class ChargerTest < ActiveSupport::TestCase
  setup do
    load_fixtures
    station = Station.find_by(name: "ELECTAR_PARIS_15")
    @charger1 = station.chargers[0]
    @charger2 = station.chargers[1]
  end

  teardown do
    Station.delete_all
  end
  
  test "sessions returns an empty array when there are no sessions" do
    sessions = @charger1.sessions

    assert_equal([], sessions)
  end

  test "sessions returns the sessions linked to the charger" do
    session1 = Session.create(connector: @charger1.connectors[0])
    session2 = Session.create(connector: @charger1.connectors[1])

    sessions = @charger1.sessions

    assert_equal([session1, session2], sessions)
  end

  test "sessions does not return sessions linked to another charger" do
    session1 = Session.create(connector: @charger1.connectors[0])
    session2 = Session.create(connector: @charger2.connectors[0])

    sessions = @charger1.sessions

    assert_equal([session1], sessions)
  end

  test "average_power returns max_power when there are no session" do
    power = @charger1.average_power

    assert_equal(@charger1.max_power, power)
  end

  test "average_power returns the average power available for each session" do
    Session.create(connector: @charger1.connectors[0])
    Session.create(connector: @charger1.connectors[1])

    power = @charger1.average_power

    assert_equal((@charger1.max_power ./ 2), power)
  end

  test "create_session fails when adding for an invalid connector" do
    assert_raises ArgumentError, "invalid connector_id for this station" do
      @charger1.create_session(42, 150)
    end
  end

  test "create_session fails when the connector is unavailable" do
    connector = @charger1.connectors[0]
    Session.create(connector: connector)

    assert_raises UnavailableConnectorError, "cannot charge on an unavailble connector" do
      @charger1.create_session(connector.id, 150)
    end
  end

  test "create_session creates a new session linked to the provided connector" do
    connector = @charger1.connectors[0]

    session = @charger1.create_session(connector.id, 150)

    assert_equal(connector, session.connector)
    assert_equal(150, session.vehicle_max_power)
  end
end
