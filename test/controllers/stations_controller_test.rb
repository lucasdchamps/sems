require "test_helper"

class StationControllerTest < ActionDispatch::IntegrationTest
  setup do
    load_fixtures
    @station = Station.find_by(name: "ELECTAR_PARIS_15")
    @charger = @station.chargers[0]
    @connector = @charger.connectors[0]
  end

  teardown do
    Station.delete_all
  end

  test "status should fail when called on a non-existing station" do
    get station_status_path(42)
    
    assert_response :not_found
  end

  test "status should return an empty array when there are no session" do
    get station_status_path(@station.id)
    
    assert_response :success
    assert_equal([], JSON.parse(@response.body))
  end

  test "status should return the status of the found station" do
    session1 = Session.create(connector: @charger.connectors[0], allocated_power: 100)
    session2 = Session.create(connector: @charger.connectors[1], allocated_power: 150)
    
    get station_status_path(@station.id)

    assert_response :success
    assert_equal([{
        "session_id" => session1.id.to_s,
        "allocated_power" => session1.allocated_power
    }, {
        "session_id" => session2.id.to_s,
        "allocated_power" => session2.allocated_power
    }], JSON.parse(@response.body))
  end

  test "create_session should fail when called on a non-existing station" do
    post create_session_path(42)
    
    assert_response :not_found
  end

  test "create_session should create a session within the found station and load balance the station" do
    post create_session_path(@station.id.to_s, {
      charger_id: @charger.id.to_s,
      connector_id: @connector.id.to_s,
      vehicle_max_power: 150
    })
    
    session = JSON.parse(@response.body)
    station = Station.find_by(name: "ELECTAR_PARIS_15")
    assert_response :success
    assert_equal(150, session["allocated_power"])
    assert_equal(station.chargers[0].sessions[0].id.to_s, session["session_id"])
  end

  test "delete_session should fail when called on a non-existing station" do
    delete delete_session_path(42, session_id: 42)
    
    assert_response :not_found
  end

  test "delete_session should delete an existing and reallocate power" do
    session1 = Session.create(connector: @charger.connectors[0], allocated_power: 100, vehicle_max_power: 150)
    session2 = Session.create(connector: @charger.connectors[1], allocated_power: 100, vehicle_max_power: 150)

    delete delete_session_path(@station.id, session_id: session1.id.to_s)

    station = Station.find_by(name: "ELECTAR_PARIS_15")
    assert_equal([{
        session_id: session2.id,
        allocated_power: 150
    }], station.status)
  end
end
