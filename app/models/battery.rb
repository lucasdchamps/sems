class Battery
  include Mongoid::Document
  include Mongoid::Timestamps
  field :capacity, type: Integer
  field :power, type: Integer

  embedded_in :station
end
