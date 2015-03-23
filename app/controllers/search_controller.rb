class SearchController < ApplicationController

	def typeahead
		@players = Player.where("name like ?", "%#{params[:query]}%").select("name, id")

		render json: @players
	end
end
