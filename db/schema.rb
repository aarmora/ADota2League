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

ActiveRecord::Schema.define(:version => 20140303232250) do

  create_table "games", :id => false, :force => true do |t|
  end

  create_table "matches", :id => false, :force => true do |t|
  end

  create_table "players", :id => false, :force => true do |t|
  end

  create_table "players_teams", :id => false, :force => true do |t|
  end

  create_table "teams", :id => false, :force => true do |t|
  end

  create_table "userprofile", :id => false, :force => true do |t|
  end

  create_table "webpages_membership", :id => false, :force => true do |t|
  end

  create_table "webpages_oauthmembership", :id => false, :force => true do |t|
  end

  create_table "webpages_roles", :id => false, :force => true do |t|
  end

  create_table "webpages_usersinroles", :id => false, :force => true do |t|
  end

end
