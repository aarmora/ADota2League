class MatchesController < ApplicationController
	def index
	end
  def show
    @match = Match.find(params[:id])
    unless @match.home_team.nil?
      @home_team_roster = @match.home_team.players.sort_by {|p| p.id == @match.home_team.captain_id ? 0 : 1}
    end
    unless @match.away_team.nil?
      @away_team_roster = @match.away_team.players.sort_by {|p| p.id == @match.away_team.captain_id ? 0 : 1}
    end
    @matchcomments = Matchcomment.where(:match_id => params[:id]).order("created_at desc")
  end

  def update
    @match = Match.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit? @match

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
    respond_to do |format|
      # Possibly email the team or captain when a comment is made
      #UserMailer.match_comment_email(params[:matchcomment][:match_id]).deliver

      format.html { render :partial => 'match_comments', :object => @matchcomments }
      #format.json { render :partial => 'match_comment', :object => @matchcomments }

    end
  end

  def delete_match_comment
    Matchcomment.find(params[:comment_id]).destroy
    render :nothing => true
  end

  def match_comments_partial
    @matchcomments = Matchcomment.where(:match_id => params[:match_id]).order("created_at desc")
    render :partial => 'match_comments', :object => @matchcomments
  end

end
