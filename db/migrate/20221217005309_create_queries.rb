class CreateQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :queries do |t|
      t.text :query, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
