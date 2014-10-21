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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141019163740) do

  create_table "games", :force => true do |t|
    t.integer  "match_id"
    t.integer  "steam_match_id"
    t.string   "dire_team_name",       :limit => 50
    t.integer  "dire_dota_team_id"
    t.string   "radiant_team_name",    :limit => 50
    t.integer  "radiant_dota_team_id"
    t.boolean  "radiant_win"
    t.integer  "game_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dire_team_id"
    t.integer  "radiant_team_id"
  end

  add_index "games", ["match_id"], :name => "index_games_on_match_id"

  create_table "inhousegames", :force => true do |t|
    t.integer  "barracks_status_dire"
    t.integer  "barracks_status_radiant"
    t.integer  "cluster"
    t.integer  "dire_captain"
    t.integer  "duration"
    t.integer  "first_blood_time"
    t.integer  "game_mode"
    t.integer  "human_players"
    t.integer  "leagueid"
    t.integer  "match_id"
    t.integer  "match_seq_num"
    t.integer  "radiant_captain"
    t.integer  "radiant_win"
    t.integer  "start_time"
    t.integer  "tower_status_dire"
    t.integer  "account_id"
    t.integer  "assists"
    t.integer  "deaths"
    t.integer  "denies"
    t.integer  "gold_per_min"
    t.integer  "gold_spent"
    t.integer  "hero_damage"
    t.integer  "hero_healing"
    t.integer  "hero_id"
    t.integer  "kills"
    t.integer  "last_hits"
    t.integer  "leaver_status"
    t.integer  "level"
    t.integer  "tower_damage"
    t.integer  "xp_per_min"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "player_slot"
    t.boolean  "checked",                 :default => false, :null => false
  end

  create_table "inhouseleaderboards", :force => true do |t|
    t.integer "player_id"
    t.integer "account_id"
    t.integer "season_id"
    t.integer "wins"
    t.integer "games_played"
    t.integer "kills"
    t.integer "deaths"
    t.integer "assists"
  end

  create_table "matchcomments", :force => true do |t|
    t.integer  "match_id"
    t.integer  "player_id"
    t.text     "comment"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "auto_generated", :default => false, :null => false
  end

  add_index "matchcomments", ["match_id"], :name => "index_matchcomments_on_match_id"

  create_table "matches", :force => true do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.string   "steam_match_id",      :limit => 50
    t.datetime "date"
    t.integer  "home_score"
    t.integer  "away_score"
    t.boolean  "is_disputed"
    t.boolean  "is_live"
    t.integer  "caster_id"
    t.integer  "week"
    t.integer  "season"
    t.integer  "season_id"
    t.boolean  "forfeit"
    t.boolean  "mmr_processed",                     :default => false, :null => false
    t.integer  "challonge_id"
    t.string   "lobby_password"
    t.datetime "reschedule_time"
    t.integer  "reschedule_proposer"
  end

  add_index "matches", ["away_team_id"], :name => "index_matches_on_away_team_id"
  add_index "matches", ["home_team_id"], :name => "index_matches_on_home_team_id"
  add_index "matches", ["season_id"], :name => "index_matches_on_season_id"

  create_table "permissions", :force => true do |t|
    t.integer "player_id"
    t.string  "permission_mode"
    t.integer "organization_id"
    t.integer "season_id"
    t.string  "division"
  end

  add_index "permissions", ["player_id"], :name => "index_permissions_on_player_id"

  create_table "player_comments", :force => true do |t|
    t.integer  "commenter_id"
    t.integer  "recipient_id"
    t.text     "comment"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "player_votes", :force => true do |t|
    t.integer "endorser_id"
    t.integer "recipient_id"
  end

  add_index "player_votes", ["endorser_id"], :name => "index_player_votes_on_endorser_id"
  add_index "player_votes", ["recipient_id"], :name => "index_player_votes_on_recipient_id"

  create_table "players", :force => true do |t|
    t.integer  "team_id"
    t.string   "name",               :limit => 100
    t.string   "email",              :limit => 50
    t.string   "steamid",            :limit => 50
    t.boolean  "cptflag"
    t.boolean  "freeagentflag"
    t.string   "role",               :limit => 100
    t.string   "steam32id",          :limit => 50
    t.boolean  "caster"
    t.string   "region",             :limit => 50
    t.string   "twitch",             :limit => 50
    t.integer  "clickedprobuilt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio"
    t.boolean  "admin"
    t.integer  "endorsements_count",                :default => 0, :null => false
    t.integer  "mmr"
    t.integer  "hours_played"
    t.string   "stripe_customer_id"
    t.string   "time_zone"
  end

  create_table "players_teams", :force => true do |t|
    t.integer "player_id"
    t.integer "team_id"
  end

  add_index "players_teams", ["player_id"], :name => "index_players_teams_on_player_id"
  add_index "players_teams", ["team_id"], :name => "index_players_teams_on_team_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "author_id"
  end

  create_table "seasons", :force => true do |t|
    t.integer  "league_id"
    t.string   "title"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "registration_open"
    t.boolean  "active",            :default => false, :null => false
    t.datetime "late_fee_start"
    t.integer  "price_cents",       :default => 0,     :null => false
    t.integer  "late_price_cents",  :default => 0,     :null => false
    t.integer  "exclusive_group"
    t.integer  "challonge_id"
    t.string   "challonge_url"
    t.string   "challonge_type"
    t.datetime "start_date"
    t.text     "description"
  end

  create_table "team_seasons", :force => true do |t|
    t.integer  "team_id"
    t.integer  "season_id"
    t.string   "division"
    t.boolean  "paid",             :default => false, :null => false
    t.integer  "price_paid_cents", :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "checked_in",       :default => false, :null => false
  end

  add_index "team_seasons", ["season_id", "division"], :name => "index_team_seasons_on_season_id_and_division"
  add_index "team_seasons", ["team_id"], :name => "index_team_seasons_on_team_id"

  create_table "teams", :force => true do |t|
    t.string   "teamname",     :limit => 300
    t.integer  "captain_id"
    t.boolean  "tuesdayflag"
    t.boolean  "thursdayflag"
    t.string   "region",       :limit => 50
    t.integer  "dotabuff_id"
    t.integer  "originalmmr"
    t.integer  "mmr"
    t.boolean  "active",                      :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
