class MatchesController < ApplicationController
	def index

	end

  def new
    raise ActionController::RoutingError.new('Not Found') unless Permissions.user_is_site_admin?(@current_user)
    @teams = [["", ""]] + Team.order(:teamname).all.map { |team| [team.teamname, team.id]}
    @seasons = [["", ""]] + Season.where(:active => true).map { |season| [season.id, season.id]}


  end

  def create
    raise ActionController::RoutingError.new('Not Found') unless Permissions.user_is_site_admin?(@current_user)
    @match = Match.new
    @match.lobby_password = "ad2l" + rand(1000).to_s
    @match.update_attributes(params[:match], :as => @current_user.role_for_object(@match))
    @match.date = Date.today
    @match.reschedule_time = Date.today
    @match.save!
    redirect_to @match

  end

  def show

    @match = Match.find(params[:id])
    unless @match.home_team.nil?
      @home_team_roster = @match.home_team.players.sort_by {|p| p.id == @match.home_team.captain_id ? 0 : 1}
    end
    unless @match.away_team.nil?
      @away_team_roster = @match.away_team.players.sort_by {|p| p.id == @match.away_team.captain_id ? 0 : 1}
    end
    @matchcomments = @match.matchcomments
    @casters = Player.order("name ASC").where(:caster => true)

    if @match.home_team && @match.away_team
      @can_edit = @current_user && (@match.away_team.captain_id === @current_user.id || @match.home_team.captain_id === @current_user.id)
    end
  end

  def accept_reschedule
    @match = Match.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless (Permissions.can_edit?(@match) && @match.reschedule_proposer) || (@can_edit && @match.reschedule_proposer)
    if @match.reschedule_proposer != @current_user.id
      @match.date = @match.reschedule_time
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

    if @match.home_team && @match.away_team
      @can_edit = @current_user && (@match.away_team.captain_id === @current_user.id || @match.home_team.captain_id === @current_user.id)
    end

    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit?(@match) || @can_edit

    if params[:match][:home_team]
      params[:match][:home_team_id] = params[:match][:home_team]
      params[:match][:home_team] = nil
    end

    if params[:match][:away_team]
      params[:match][:away_team_id] = params[:match][:away_team]
      params[:match][:away_team] = nil
    end

    # do reschedule handling
    if params[:match][:reschedule_time] && @current_user.role_for_object(@match) == :captain
      @match.reschedule_proposer = @current_user.id
      UserMailer.reschedule_proposed(params[:match][:date], @match, @current_user).deliver
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
