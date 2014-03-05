class TeamsController < ApplicationController
	def index
		@teams = Team.where("season is not null")
		@x = 3
		@teams.each do |pizza|
			@x = @x + 77
		end
	end
	def show
		@team = Team.find(params[:id])
	end
end
