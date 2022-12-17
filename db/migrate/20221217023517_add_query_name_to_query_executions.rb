class AddQueryNameToQueryExecutions < ActiveRecord::Migration[7.0]
  def change
    add_column :query_executions, :query_name, :string
  end
end
