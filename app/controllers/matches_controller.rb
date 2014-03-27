class MatchesController < ApplicationController
	def index
		@leaguematches = Dota.history(:league_id => 158)

		#@matchdetails = Dota.match(22345678)
	end
  def update
  	@match = Match.find(params[:id])

    respond_to do |format|
      if @match.update_attributes(params[:match], :as => @current_user.permission_role)
        format.html { redirect_to(@match, :notice => 'Player was successfully updated.') }
        format.json { respond_with_bip(@match) }
      else
        format.html { render :action => "show" }
        format.json { respond_with_bip(@match) }
      end
    end
  end
end
