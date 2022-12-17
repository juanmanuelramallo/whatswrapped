class CreateQueryExecutions < ActiveRecord::Migration[7.0]
  def change
    create_table :query_executions do |t|
      t.references :query, null: false, foreign_key: true
      t.references :report, null: false, foreign_key: true
      t.jsonb :variables
      t.jsonb :result, null: false

      t.timestamps
    end
  end
end
