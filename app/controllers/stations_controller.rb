class StationsController < ApplicationController
  def status
    render json: Station.find(params[:id]).status
  end

  def create_session
    station = Station.find(params[:id])
    session = station.create_session(
      BSON::ObjectId.from_string(params[:charger_id]),
      BSON::ObjectId.from_string(params[:connector_id]),
      params[:vehicle_max_power]
    )
    render json: { session_id: session.id, allocated_power: session.allocated_power }
  end
end
