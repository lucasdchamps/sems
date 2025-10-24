class UnavailableConnectorError < StandardError
end

class Charger
  include Mongoid::Document
  include Mongoid::Timestamps
  field :max_power, type: Integer

  embedded_in :station
  embeds_many :connectors

  def sessions
    self.connectors.map(&:session).compact
  end

  def create_session(connector_id, vehicle_max_power)
    connector = self.connectors.find { |connector| connector.id == connector_id }
    raise ArgumentError.new "invalid connector_id for this charger" unless connector
    raise UnavailableConnectorError.new "cannot charge on an unavailble connector" unless connector.available?

    Session.new(connector: connector, vehicle_max_power: vehicle_max_power)
  end

  def average_power
    return self.max_power if self.sessions.size == 0
    
    self.max_power ./ self.sessions.size
  end
end
