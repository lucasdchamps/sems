require "test_helper"

class StationControllerTest < ActionDispatch::IntegrationTest
  setup do
    load_fixtures
    @station = Station.find_by(name: "ELECTAR_PARIS_15")
    @charger = @station.chargers[0]
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
end
