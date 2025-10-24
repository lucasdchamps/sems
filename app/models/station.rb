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

  private
  
  def sessions
    self.chargers.map(&:sessions).flatten
  end
end
