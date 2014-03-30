class MatchesController < ApplicationController
	def index
	end
  def show
    @match = Match.find(params[:id])
    @home_team_roster = @match.home_team.players
    @away_team_roster = @match.away_team.players
    @matchcomments = Matchcomment.where(:match_id => params[:id]).order("created_at desc")
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

  def create_match_comment
    @match_comment = Matchcomment.new
    @match_comment.player_id = @current_user.id
    @match_comment.attributes = params[:matchcomment]
    @match_comment.save!
    @matchcomments = Matchcomment.where(:match_id => params[:matchcomment][:match_id]).order("created_at desc")
    render :partial => 'match_comment', :object => @matchcomments
  end

  def match_comments_partial
    @matchcomments = Matchcomment.where(:match_id => params[:match_id]).order("created_at desc")
    render :partial => 'match_comment', :object => @matchcomments
  end

end
