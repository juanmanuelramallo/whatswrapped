class Report < ApplicationRecord
  attribute :uuid, :uuid, default: -> { SecureRandom.uuid }

  has_many :query_executions, dependent: :destroy

  def to_param
    uuid
  end
end
