class AddQueryToQueryExecutions < ActiveRecord::Migration[7.0]
  def change
    add_column :query_executions, :query, :text
  end
end
