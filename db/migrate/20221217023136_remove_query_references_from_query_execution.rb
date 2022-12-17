class RemoveQueryReferencesFromQueryExecution < ActiveRecord::Migration[7.0]
  def change
    remove_reference :query_executions, :query, index: true, foreign_key: true
  end
end
