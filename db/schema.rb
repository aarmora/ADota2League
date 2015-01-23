# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150123200253) do

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size",    limit: 4
    t.integer  "assetable_id",      limit: 4
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "match_id",             limit: 4
    t.integer  "steam_match_id",       limit: 4
    t.string   "dire_team_name",       limit: 50
    t.integer  "dire_dota_team_id",    limit: 4
    t.string   "radiant_team_name",    limit: 50
    t.integer  "radiant_dota_team_id", limit: 4
    t.boolean  "radiant_win",          limit: 1
    t.integer  "game_code",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dire_team_id",         limit: 4
    t.integer  "radiant_team_id",      limit: 4
  end

  add_index "games", ["match_id"], name: "index_games_on_match_id", using: :btree

  create_table "inhousegames", force: :cascade do |t|
    t.integer  "barracks_status_dire",    limit: 4
    t.integer  "barracks_status_radiant", limit: 4
    t.integer  "cluster",                 limit: 4
    t.integer  "dire_captain",            limit: 4
    t.integer  "duration",                limit: 4
    t.integer  "first_blood_time",        limit: 4
    t.integer  "game_mode",               limit: 4
    t.integer  "human_players",           limit: 4
    t.integer  "leagueid",                limit: 4
    t.integer  "match_id",                limit: 4
    t.integer  "match_seq_num",           limit: 4
    t.integer  "radiant_captain",         limit: 4
    t.integer  "radiant_win",             limit: 4
    t.integer  "start_time",              limit: 4
    t.integer  "tower_status_dire",       limit: 4
    t.integer  "account_id",              limit: 4
    t.integer  "assists",                 limit: 4
    t.integer  "deaths",                  limit: 4
    t.integer  "denies",                  limit: 4
    t.integer  "gold_per_min",            limit: 4
    t.integer  "gold_spent",              limit: 4
    t.integer  "hero_damage",             limit: 4
    t.integer  "hero_healing",            limit: 4
    t.integer  "hero_id",                 limit: 4
    t.integer  "kills",                   limit: 4
    t.integer  "last_hits",               limit: 4
    t.integer  "leaver_status",           limit: 4
    t.integer  "level",                   limit: 4
    t.integer  "tower_damage",            limit: 4
    t.integer  "xp_per_min",              limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "player_slot",             limit: 4
    t.boolean  "checked",                 limit: 1, default: false, null: false
  end

  create_table "inhouseleaderboards", force: :cascade do |t|
    t.integer "player_id",    limit: 4
    t.integer "account_id",   limit: 4
    t.integer "season_id",    limit: 4
    t.integer "wins",         limit: 4
    t.integer "games_played", limit: 4
    t.integer "kills",        limit: 4
    t.integer "deaths",       limit: 4
    t.integer "assists",      limit: 4
  end

  create_table "matchcomments", force: :cascade do |t|
    t.integer  "match_id",       limit: 4
    t.integer  "player_id",      limit: 4
    t.text     "comment",        limit: 65535
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "auto_generated", limit: 1,     default: false, null: false
  end

  add_index "matchcomments", ["match_id"], name: "index_matchcomments_on_match_id", using: :btree

  create_table "matches", force: :cascade do |t|
    t.integer  "home_team_id",        limit: 4
    t.integer  "away_team_id",        limit: 4
    t.string   "steam_match_id",      limit: 50
    t.datetime "date"
    t.integer  "home_score",          limit: 4
    t.integer  "away_score",          limit: 4
    t.boolean  "is_disputed",         limit: 1
    t.boolean  "is_live",             limit: 1
    t.integer  "caster_id",           limit: 4
    t.integer  "week",                limit: 4
    t.integer  "season",              limit: 4
    t.integer  "season_id",           limit: 4
    t.boolean  "forfeit",             limit: 1
    t.boolean  "mmr_processed",       limit: 1,   default: false, null: false
    t.integer  "challonge_id",        limit: 4
    t.string   "lobby_password",      limit: 255
    t.datetime "reschedule_time"
    t.integer  "reschedule_proposer", limit: 4
  end

  add_index "matches", ["away_team_id"], name: "index_matches_on_away_team_id", using: :btree
  add_index "matches", ["home_team_id"], name: "index_matches_on_home_team_id", using: :btree
  add_index "matches", ["season_id"], name: "index_matches_on_season_id", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer "player_id",       limit: 4
    t.string  "permission_mode", limit: 255
    t.integer "organization_id", limit: 4
    t.integer "season_id",       limit: 4
    t.string  "division",        limit: 255
  end

  add_index "permissions", ["player_id"], name: "index_permissions_on_player_id", using: :btree

  create_table "player_comments", force: :cascade do |t|
    t.integer  "commenter_id", limit: 4
    t.integer  "recipient_id", limit: 4
    t.text     "comment",      limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "player_votes", force: :cascade do |t|
    t.integer "endorser_id",  limit: 4
    t.integer "recipient_id", limit: 4
  end

  add_index "player_votes", ["endorser_id"], name: "index_player_votes_on_endorser_id", using: :btree
  add_index "player_votes", ["recipient_id"], name: "index_player_votes_on_recipient_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.integer  "team_id",            limit: 4
    t.string   "name",               limit: 100
    t.string   "email",              limit: 50
    t.string   "steamid",            limit: 50
    t.boolean  "cptflag",            limit: 1
    t.boolean  "freeagentflag",      limit: 1
    t.string   "role",               limit: 100
    t.string   "steam32id",          limit: 50
    t.boolean  "caster",             limit: 1
    t.string   "region",             limit: 50
    t.string   "twitch",             limit: 50
    t.integer  "clickedprobuilt",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio",                limit: 65535
    t.boolean  "admin",              limit: 1
    t.integer  "endorsements_count", limit: 4,     default: 0, null: false
    t.integer  "mmr",                limit: 4
    t.integer  "hours_played",       limit: 4
    t.string   "stripe_customer_id", limit: 255
    t.string   "time_zone",          limit: 255
    t.integer  "comments_count",     limit: 4,     default: 0, null: false
  end

  create_table "players_teams", force: :cascade do |t|
    t.integer "player_id", limit: 4
    t.integer "team_id",   limit: 4
  end

  add_index "players_teams", ["player_id"], name: "index_players_teams_on_player_id", using: :btree
  add_index "players_teams", ["team_id"], name: "index_players_teams_on_team_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "author_id",  limit: 4
  end

  create_table "seasons", force: :cascade do |t|
    t.integer  "league_id",         limit: 4
    t.string   "title",             limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "registration_open", limit: 1
    t.boolean  "active",            limit: 1,     default: false, null: false
    t.datetime "late_fee_start"
    t.integer  "price_cents",       limit: 4,     default: 0,     null: false
    t.integer  "late_price_cents",  limit: 4,     default: 0,     null: false
    t.integer  "exclusive_group",   limit: 4
    t.integer  "challonge_id",      limit: 4
    t.string   "challonge_url",     limit: 255
    t.string   "challonge_type",    limit: 255
    t.datetime "start_date"
    t.text     "description",       limit: 65535
  end

  create_table "team_seasons", force: :cascade do |t|
    t.integer  "team_id",          limit: 4
    t.integer  "season_id",        limit: 4
    t.string   "division",         limit: 255
    t.boolean  "paid",             limit: 1,   default: false, null: false
    t.integer  "price_paid_cents", limit: 4,   default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "checked_in",       limit: 1,   default: false, null: false
  end

  add_index "team_seasons", ["season_id", "division"], name: "index_team_seasons_on_season_id_and_division", using: :btree
  add_index "team_seasons", ["team_id"], name: "index_team_seasons_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "teamname",     limit: 300
    t.integer  "captain_id",   limit: 4
    t.boolean  "tuesdayflag",  limit: 1
    t.boolean  "thursdayflag", limit: 1
    t.string   "region",       limit: 50
    t.integer  "dotabuff_id",  limit: 4
    t.integer  "originalmmr",  limit: 4
    t.integer  "mmr",          limit: 4
    t.boolean  "active",       limit: 1,   default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "userprofile", primary_key: "userid", force: :cascade do |t|
    t.string "username", limit: 56, null: false
  end

  add_index "userprofile", ["username"], name: "UQ__UserProf__C9F28456150C2377", unique: true, using: :btree

  create_table "webpages_membership", id: false, force: :cascade do |t|
    t.integer  "userid",                                  limit: 4,                   null: false
    t.datetime "createdate"
    t.string   "confirmationtoken",                       limit: 128
    t.boolean  "isconfirmed",                             limit: 1,   default: false
    t.datetime "lastpasswordfailuredate"
    t.integer  "passwordfailuressincelastsuccess",        limit: 4,   default: 0,     null: false
    t.string   "password",                                limit: 128,                 null: false
    t.datetime "passwordchangeddate"
    t.string   "passwordsalt",                            limit: 128,                 null: false
    t.string   "passwordverificationtoken",               limit: 128
    t.datetime "passwordverificationtokenexpirationdate"
  end

  create_table "webpages_oauthmembership", id: false, force: :cascade do |t|
    t.string  "provider",       limit: 30,  null: false
    t.string  "provideruserid", limit: 100, null: false
    t.integer "userid",         limit: 4,   null: false
  end

  create_table "webpages_roles", primary_key: "roleid", force: :cascade do |t|
    t.string "rolename", limit: 256, null: false
  end

  add_index "webpages_roles", ["rolename"], name: "UQ__webpages__8A2B616079931DB6", unique: true, using: :btree

  create_table "webpages_usersinroles", id: false, force: :cascade do |t|
    t.integer "userid", limit: 4, null: false
    t.integer "roleid", limit: 4, null: false
  end

end
