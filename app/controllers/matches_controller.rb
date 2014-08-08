class MatchesController < ApplicationController
	def index
	end
  def show
    Rails.logger.debug("Im Jordan and I log.")

    @match = Match.find(params[:id])
    unless @match.home_team.nil?
      @home_team_roster = @match.home_team.players.sort_by {|p| p.id == @match.home_team.captain_id ? 0 : 1}
    end
    unless @match.away_team.nil?
      @away_team_roster = @match.away_team.players.sort_by {|p| p.id == @match.away_team.captain_id ? 0 : 1}
    end
    @matchcomments = @match.matchcomments
    @casters = Player.order("name ASC").where(:caster => true)
  end

  def accept_reschedule
    @match = Match.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit?(@match) && @match.reschedule_proposer
    if @match.reschedule_proposer != @current_user.id
      @match.date = @match.reschedule_time
      @match.reschedule_time = nil
      @match.reschedule_proposer = nil
      @match.save!
      m = @match.matchcomments.build(:player_id => @current_user.id, :comment => "I have accepted the reschedule!")
      m.auto_generated = true
      m.save
    end
    redirect_to @match
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

    # do reschedule handling
    if params[:match][:date] && @current_user.role_for_object(@match) == :captain
      @match.reschedule_proposer = @current_user.id
      @match.reschedule_time = params[:match][:date]
    end

    # Log changes for later
    changes = {}
    params[:match].map do |item, value|
      changes[item] = [@match[item], value] if @match.respond_to? item
    end

    respond_to do |format|
      if @match.update_attributes(params[:match], :as => @current_user.role_for_object(@match))
        @match.create_auto_match_comments(changes, @current_user)
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
    comment = Matchcomment.find(params[:comment_id])
    comment.destroy unless comment.auto_generated
    render :nothing => true
  end

  def match_comments_partial
    @matchcomments = Matchcomment.where(:match_id => params[:match_id]).order("created_at desc")
    render :partial => 'match_comments', :object => @matchcomments
  end

end
