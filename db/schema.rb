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

ActiveRecord::Schema.define(version: 20150303234044) do

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
    t.integer  "home_participant_id",   limit: 4
    t.integer  "away_participant_id",   limit: 4
    t.string   "steam_match_id",        limit: 50
    t.datetime "date"
    t.integer  "home_score",            limit: 4
    t.integer  "away_score",            limit: 4
    t.boolean  "is_disputed",           limit: 1
    t.boolean  "is_live",               limit: 1
    t.integer  "caster_id",             limit: 4
    t.integer  "week",                  limit: 4
    t.integer  "season",                limit: 4
    t.integer  "season_id",             limit: 4
    t.boolean  "forfeit",               limit: 1
    t.boolean  "mmr_processed",         limit: 1,   default: false,  null: false
    t.integer  "challonge_id",          limit: 4
    t.string   "lobby_password",        limit: 255
    t.datetime "reschedule_time"
    t.integer  "reschedule_proposer",   limit: 4
    t.string   "home_participant_type", limit: 255, default: "Team"
    t.string   "away_participant_type", limit: 255, default: "Team"
    t.integer  "winner_match_id",       limit: 4
    t.integer  "loser_match_id",        limit: 4
  end

  add_index "matches", ["away_participant_id", "away_participant_type"], name: "index_matches_on_away_participant_id_and_away_participant_type", using: :btree
  add_index "matches", ["home_participant_id", "home_participant_type"], name: "index_matches_on_home_participant_id_and_home_participant_type", using: :btree
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
    t.text     "bio",                limit: 16777215
    t.boolean  "admin",              limit: 1
    t.integer  "endorsements_count", limit: 4,        default: 0,    null: false
    t.integer  "mmr",                limit: 4
    t.integer  "hours_played",       limit: 4
    t.string   "stripe_customer_id", limit: 255
    t.string   "time_zone",          limit: 255
    t.integer  "comments_count",     limit: 4,        default: 0,    null: false
    t.string   "real_name",          limit: 255
    t.string   "avatar",             limit: 255
    t.string   "country",            limit: 255
    t.boolean  "receive_emails",     limit: 1,        default: true
    t.string   "twitter",            limit: 255
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

  create_table "season_types", force: :cascade do |t|
    t.string "Season type", limit: 255
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
    t.boolean  "solo_league",       limit: 1,     default: false
    t.integer  "season_type",       limit: 4,     default: 0,     null: false
    t.boolean  "team_tourney",      limit: 1,     default: true
  end

  create_table "solo_league_matches", force: :cascade do |t|
    t.integer "home_team_id_1", limit: 4
    t.integer "home_team_id_2", limit: 4
    t.integer "home_team_id_3", limit: 4
    t.integer "home_team_id_4", limit: 4
    t.integer "home_team_id_5", limit: 4
    t.integer "away_team_id1",  limit: 4
    t.integer "away_team_id2",  limit: 4
    t.integer "away_team_id3",  limit: 4
    t.integer "away_team_id4",  limit: 4
    t.integer "away_team_id5",  limit: 4
    t.boolean "home_wins",      limit: 1
    t.integer "round",          limit: 4
    t.integer "season_id",      limit: 4
    t.string  "lobby_password", limit: 255
  end

  create_table "team_seasons", force: :cascade do |t|
    t.integer  "participant_id",   limit: 4
    t.integer  "season_id",        limit: 4
    t.string   "division",         limit: 255
    t.boolean  "paid",             limit: 1,   default: false,  null: false
    t.integer  "price_paid_cents", limit: 4,   default: 0,      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "checked_in",       limit: 1,   default: false,  null: false
    t.string   "participant_type", limit: 255, default: "Team", null: false
  end

  add_index "team_seasons", ["participant_id", "participant_type"], name: "index_team_seasons_on_participant_id_and_participant_type", using: :btree
  add_index "team_seasons", ["season_id", "division"], name: "index_team_seasons_on_season_id_and_division", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",         limit: 300
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

end
