class AddSessionTable < ActiveRecord::Migration
	def with_table_name_prefix(prefix)
    old_prefix = ActiveRecord::Base.table_name_prefix
    ActiveRecord::Base.table_name_prefix = prefix
    yield
  ensure
    ActiveRecord::Base.table_name_prefix = old_prefix
  end

  def up
  	with_table_name_prefix("ad2lrails.aarmora.") do
	  	create_table :seasons do |t|
			  t.integer :league_id
			  t.string :title
			  t.timestamps
			end

			create_table :team_seasons do |t|
			  t.references :team
			  t.references :season
			  t.string :division
			end

			# Indicies cannot be added in migrations with this setup, might have to do this by hand :(
			# add_index :team_seasons, [:season_id, :division]
			# add_index :team_seasons, :team_id

			add_column :matches, :season_id, :integer
			# add_index :matches, :season_id

			Team.connection.schema_cache.clear!
			Team.reset_column_information

			open_season = Season.new
			open_season.league_id = 193
			open_season.title = "Season 3 Open"
			open_season.save!

			# TODO: get the season id for this!!!
			invite_season = Season.new
			invite_season.league_id = 0
			invite_season.title = "Season 3 Invite"
			invite_season.save!

			puts "Assigning the proper seasons to all teams...hang on..."
			Team.where("season = 3").each do |team|
				team.team_seasons.create(:season => open_season, :division => team.region + "-" + team.division.to_s)
			end
			Team.where("season = 4").each do |team|
				team.team_seasons.create(:season => invite_season, :division => team.division)
			end
			puts "Assigning the proper seasons to all matches...almost there..."
			Match.includes(:away_team,:home_team).select{ |match| match.home_team && match.home_team.season && match.away_team && match.away_team.season }.each do |match|
				match.season = match.away_team.season == 3 ? open_season : invite_season
				match.save
			end

			# TODO: Drop the columns season, region, division
			remove_column :teams, :season
			# remove_column  :teams, :region # This could be useful still as a property
			remove_column :teams, :division
		end
  end

  def down
  	# NOTE: this was untested, be nice to it if you need it!
  	with_table_name_prefix("ad2lrails.aarmora.") do
	  	# re-create columns
	  	add_column :teams, :season, :integer
			# add_column :teams, :region, :string
			add_column :teams, :division, :integer

	  	# This is imperfect, but we assume the league_id will be unique, and that this shit works...so let's go with that
	  	puts "Reconstructing the attributes on the team table...this might take a minute"
	  	TeamSeason.all.each do |ts|
	  		team = ts.team
	  		if ts.season.title.include? "open"
	  			team.season = 3
	  			parts = ts.division.split("-")
	  			team.division = parts[1]
	  			team.region = parts[0]
	  		else #invite
	  			team.season = 4
	  			team.division = ts.division # lossy and not proper
	  		end
	  		team.save
	  	end

	  	drop_column :matches, :season_id

	  	drop_table :team_sessions
	  	drop_table :sessions
	  end
  end
end
