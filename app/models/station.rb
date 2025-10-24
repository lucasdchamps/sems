class Station
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :grid_capacity, type: Integer

  embeds_many :chargers
  embeds_one :battery
end
