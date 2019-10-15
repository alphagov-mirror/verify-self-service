# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_09_131400) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "certificates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "value"
    t.string "usage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "component_id"
    t.boolean "enabled", default: true
    t.string "component_type"
    t.index ["component_id"], name: "index_certificates_on_component_id"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type", null: false
    t.json "data"
    t.string "aggregate_type"
    t.uuid "aggregate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.index ["aggregate_type", "aggregate_id"], name: "index_events_on_aggregate_type_and_aggregate_id"
  end

  create_table "msa_components", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "component_type"
    t.uuid "encryption_certificate_id"
    t.string "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "team_id"
    t.string "environment", null: false
    t.index ["team_id"], name: "index_msa_components_on_team_id"
  end

  create_table "msa_components_services", id: false, force: :cascade do |t|
    t.uuid "msa_component_id"
    t.uuid "service_id"
    t.index ["msa_component_id"], name: "index_msa_components_services_on_msa_component_id"
    t.index ["service_id"], name: "index_msa_components_services_on_service_id"
  end

  create_table "services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "entity_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_services_on_entity_id", unique: true
  end

  create_table "sp_components", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "component_type"
    t.uuid "encryption_certificate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "vsp", default: false
    t.uuid "team_id"
    t.string "environment", null: false
    t.index ["team_id"], name: "index_sp_components_on_team_id"
  end

  create_table "sp_components_services", id: false, force: :cascade do |t|
    t.uuid "service_id"
    t.uuid "sp_component_id"
    t.index ["service_id"], name: "index_sp_components_services_on_service_id"
    t.index ["sp_component_id"], name: "index_sp_components_services_on_sp_component_id"
  end

  create_table "teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "team_alias"
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

end
