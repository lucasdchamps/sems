require "test_helper"

class StationTest < ActiveSupport::TestCase
  setup do
    load_fixtures
    @station = Station.find_by(name: "ELECTAR_PARIS_15")
    @charger1 = @station.chargers[0]
    @connector1 = @charger1.connectors[0]
    @connector2 = @charger1.connectors[1]
    @charger2 = @station.chargers[1]
    @connector3 = @charger2.connectors[0]
    @connector4 = @charger2.connectors[1]
  end

  teardown do
    Station.delete_all
  end

  test "create_session fails when adding for an invalid charger" do
    assert_raises ArgumentError, "invalid charger_id for this station" do
      @station.create_session(42, @charger1.connectors[0].id, 150)
    end
  end

  test "create_session allocates power to the session" do
    session1 = @station.create_session(@charger1.id, @connector1.id, 150)

    assert_equal(150, session1.allocated_power)
  end

  test "scenario 1 : create_session distributes the charger's power between EVs" do
    session1 = @station.create_session(@charger1.id, @connector1.id, 150)
    session2 = @station.create_session(@charger1.id, @connector2.id, 150)

    assert_equal(@charger1.max_power / 2, session1.allocated_power)
    assert_equal(@charger1.max_power / 2, session2.allocated_power)
  end

  test "create_session distributes the power within the grid capacity" do
    session1 = @station.create_session(@charger1.id, @connector1.id, 150)
    session2 = @station.create_session(@charger1.id, @connector2.id, 150)
    session3 = @station.create_session(@charger2.id, @connector3.id, 150)
    session4 = @station.create_session(@charger2.id, @connector4.id, 150)

    assert_equal(100, session1.allocated_power)
    assert_equal(100, session2.allocated_power)
    assert_equal(100, session3.allocated_power)
    assert_equal(100, session4.allocated_power)
  end

  test "delete_session fails when deleting a non-existent session" do
    assert_raises ArgumentError, "invalid session_id for this station" do
      @station.delete_session(42)
    end
  end

  test "delete_session should delete the station's session" do
    session = Session.create(connector: @connector1)
    
    @station.delete_session(session.id)

    assert_equal(0, Session.count)
  end

  test "scenario 2: delete_session reallocates power within grid constraint" do
    session1 = @station.create_session(@charger1.id, @connector1.id, 150)
    session2 = @station.create_session(@charger1.id, @connector2.id, 150)
    session3 = @station.create_session(@charger2.id, @connector3.id, 150)
    session4 = @station.create_session(@charger2.id, @connector4.id, 150)

    @station.delete_session(session1.id)

    assert_equal(133, session2.allocated_power)
    assert_equal(133, session3.allocated_power)
    assert_equal(134, session4.allocated_power)
  end
end
