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

ActiveRecord::Schema.define(:version => 20140308014849) do

  create_table "games", :force => true do |t|
    t.integer "match_id"
    t.integer "steam_match_id"
    t.string  "dire_team_name",    :limit => 50
    t.integer "dire_team_id"
    t.string  "radiant_team_name", :limit => 50
    t.integer "radiant_team_id"
    t.string  "radiantwin",        :limit => 50
    t.integer "game_code"
  end

  create_table "matches", :force => true do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.string   "steam_match_id", :limit => 50
    t.datetime "date"
    t.integer  "home_score"
    t.integer  "away_score"
    t.boolean  "is_disputed"
    t.boolean  "is_live"
    t.integer  "twitch"
    t.integer  "week"
    t.integer  "season"
    t.integer  "season_id"
  end

  create_table "players", :force => true do |t|
    t.integer "team_id"
    t.string  "name",          :limit => 100
    t.string  "email",         :limit => 50
    t.string  "steamid",       :limit => 50
    t.boolean "cptflag"
    t.boolean "freeagentflag"
    t.string  "role",          :limit => 100
    t.string  "steam32id",     :limit => 50
    t.boolean "caster"
    t.string  "region",        :limit => 50
    t.string  "twitch",        :limit => 50
  end

  create_table "players_teams", :force => true do |t|
    t.integer "player_id"
    t.integer "team_id"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "seasons", :force => true do |t|
    t.integer  "league_id"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "team_seasons", :force => true do |t|
    t.integer "team_id"
    t.integer "season_id"
    t.string  "division"
  end

  create_table "teams", :force => true do |t|
    t.string  "teamname",     :limit => 300
    t.integer "captain_id"
    t.boolean "tuesdayflag"
    t.boolean "thursdayflag"
    t.string  "region",       :limit => 50
    t.integer "dotabuff_id"
    t.integer "originalmmr"
    t.integer "mmr"
  end

  create_table "userprofile", :primary_key => "userid", :force => true do |t|
    t.string "username", :limit => 56, :null => false
  end

  add_index "userprofile", ["UserName"], :name => "UQ__UserProf__C9F28456150C2377", :unique => true

  create_table "webpages_membership", :id => false, :force => true do |t|
    t.integer  "userid",                                                                    :null => false
    t.datetime "createdate"
    t.string   "confirmationtoken",                       :limit => 128
    t.boolean  "isconfirmed",                                            :default => false
    t.datetime "lastpasswordfailuredate"
    t.integer  "passwordfailuressincelastsuccess",                       :default => 0,     :null => false
    t.string   "password",                                :limit => 128,                    :null => false
    t.datetime "passwordchangeddate"
    t.string   "passwordsalt",                            :limit => 128,                    :null => false
    t.string   "passwordverificationtoken",               :limit => 128
    t.datetime "passwordverificationtokenexpirationdate"
  end

  create_table "webpages_oauthmembership", :id => false, :force => true do |t|
    t.string  "provider",       :limit => 30,  :null => false
    t.string  "provideruserid", :limit => 100, :null => false
    t.integer "userid",                        :null => false
  end

  create_table "webpages_roles", :primary_key => "roleid", :force => true do |t|
    t.string "rolename", :limit => 256, :null => false
  end

  add_index "webpages_roles", ["RoleName"], :name => "UQ__webpages__8A2B616079931DB6", :unique => true

  create_table "webpages_usersinroles", :id => false, :force => true do |t|
    t.integer "userid", :null => false
    t.integer "roleid", :null => false
  end

end
