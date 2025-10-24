class InvalidLoadBalancingError < StandardError
end

class Station
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :grid_capacity, type: Integer

  embeds_many :chargers
  embeds_one :battery

  def status
    self.sessions.map do |session|
      {
        session_id: session.id,
        allocated_power: session.allocated_power
      }
    end
  end

  def create_session(charger_id, connector_id, vehicle_max_power)
    charger = self.chargers.find { |charger| charger.id == charger_id }
    raise ArgumentError.new "invalid charger_id for this station" unless charger

    session = charger.create_session(connector_id, vehicle_max_power)
    self.load_balance
    session
  end

  def delete_session(session_id)
    session = self.sessions.find { |session| session.id == session_id }
    raise ArgumentError.new "invalid session_id for this station" unless session
    
    session.delete
    self.load_balance
  end

  private
  
  def sessions
    self.chargers.map(&:sessions).flatten
  end

  def load_balance
    remaning_allocations = self.sessions.size
    remaining_capacity = self.grid_capacity
    
    self.chargers.each do |charger|
      charger.sessions.each do |session|
        average_capacity = remaining_capacity / remaning_allocations
        session.allocated_power = [session.vehicle_max_power, average_capacity, charger.average_power].min
        remaining_capacity -= session.allocated_power
        remaning_allocations -= 1
      end
    end

    total_allocated = self.sessions.map(&:allocated_power).reduce(:+) || 0
    raise InvalidLoadBalancingError.new "Load balance result would exceed grid capacity" if total_allocated > self.grid_capacity

    self.save
  end
end
