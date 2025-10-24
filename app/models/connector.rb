class Connector
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :charger
  embeds_one :session
end
