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
end
