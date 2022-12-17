class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.uuid :uuid, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
