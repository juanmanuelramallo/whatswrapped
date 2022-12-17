class Report < ApplicationRecord
  attribute :uuid, :uuid, default: -> { SecureRandom.uuid }
end
