class Query < ApplicationRecord
  validates :name, :query, presence: true

  def to_sql(variables = {})
    ERB.new(query).result_with_hash(variables)
  end
end
