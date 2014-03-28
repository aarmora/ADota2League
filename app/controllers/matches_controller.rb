class MatchesController < ApplicationController
	def index
	end
  def show
    @match = Match.find(params[:id])
    @home_team_roster = @match.home_team.players
    @away_team_roster = @match.away_team.players
  end

  def update
    raise ActionController::RoutingError.new('Not Found') unless @current_user && @current_user.is_admin?
  	@match = Match.find(params[:id])

    if params[:match][:home_team]
      params[:match][:home_team_id] = params[:match][:home_team]
      params[:match][:home_team] = nil
    end

    if params[:match][:away_team]
      params[:match][:away_team_id] = params[:match][:away_team]
      params[:match][:away_team] = nil
    end


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
