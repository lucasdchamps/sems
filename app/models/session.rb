class Session
  include Mongoid::Document
  include Mongoid::Timestamps
  field :vehicle_max_power, type: Integer
  field :allocated_power, type: Integer

  embedded_in :connector
end
