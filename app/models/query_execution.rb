class QueryExecution < ApplicationRecord
  belongs_to :query
  belongs_to :report

  validates :result, presence: true
end
