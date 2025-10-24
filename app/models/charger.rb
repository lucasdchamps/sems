class Charger
  include Mongoid::Document
  include Mongoid::Timestamps
  field :max_power, type: Integer

  embedded_in :station
  embeds_many :connectors
end
