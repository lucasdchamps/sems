class StationsController < ApplicationController
  def status
    render json: Station.find(params[:id]).status
  end
end
