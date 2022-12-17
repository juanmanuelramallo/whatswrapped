# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_12_17_023517) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "queries", force: :cascade do |t|
    t.text "query", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "query_executions", force: :cascade do |t|
    t.bigint "report_id", null: false
    t.jsonb "variables"
    t.jsonb "result", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "query"
    t.string "query_name"
    t.index ["report_id"], name: "index_query_executions_on_report_id"
  end

  create_table "reports", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_reports_on_uuid", unique: true
  end

  add_foreign_key "query_executions", "reports"
end
