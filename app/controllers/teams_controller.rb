class TeamsController < ApplicationController

  def index
    @current_tab = 'teams'

    @teams = Team.includes(:seasons, :captain).where(active: true, seasons: { active: true })
	end

	def show
    @team = Team.includes({:team_seasons => [:season], :players => [], :away_matches => [:away_participant, :home_participant], :home_matches => [:away_participant, :home_participant]}).find(params[:id])
    if request.format == :ics
      # Create an ical format feed of the given team's calendar.

        require 'icalendar'
        require 'icalendar/tzinfo'

        # Create a calendar with an event (standard method)
        cal = Icalendar::Calendar.new

        if @team.matches.any? {|m| m.date }
          tzid = @team.matches.detect{|m| m.date }.date.zone
          tz = TZInfo::Timezone.get tzid
          timezone = tz.ical_timezone Time.now
          cal.add_timezone timezone
        end

        @team.matches.select{|m| m.date }.each do |match|
          # fill in the data for this event, each session acts like a repeating event
          if match.season
            desc = "AD2L #{match.season.title}"
          else
            desc = "AD2L"
          end
          desc = desc + " cast by: #{match.caster.name} (#{match.caster.twitch})" unless match.caster_id.blank?
          end_time = match.date + 3.hours
          # Build the event
          cal.event do |e|
            e.dtstart = Icalendar::Values::DateTime.new match.date, 'tzid' => tzid
            e.dtend   = Icalendar::Values::DateTime.new end_time, 'tzid' => tzid
            e.summary = match.home_participant.name + " vs. " + match.away_participant.name unless !match.away_participant || !match.home_participant
            e.description = desc
            e.url     = "http://amateurdota2league.com/matches/#{match.id}" #shows in iCal only
          end
        end

        #puts cal.to_ical
        head :unprocessable_entity if !cal

        # We did it! Make it look like a file.
        send_data(cal.to_ical, :type => 'text/calendar', :filename => params[:id] + '.ics' )
        return
    else
      if @current_user
  			@current_user.teams.each do |team|
  				if @team.id == team.id
  					@current_tab = "teampage"
  				end
  			end
  		end
  		@roster = @team.players.to_a.sort_by {|p| p.id == @team.captain_id ? 0 : 1}
  		@casters = Player.order(:name).where(:caster => true)
  		@permissions = Permission.includes(:player).all
    end
	end

	def create
		raise unless @current_user
		@team = Team.new
		@team.captain_id = @current_user.id
		@team.attributes = team_params
		@team.players << @current_user
    	@team.mmr = @team.originalmmr || @team.default_mmr
		@team.save!
    respond_to do |format|
      format.html { redirect_to(@team, :notice => 'Your new team was successfully created. Good Luck!') }
      format.json { render json: @team, :status => 200 }
    end
	end

	def update
		@team = Team.find(params[:id])
		head :forbidden and return unless Permissions.can_edit? @team
		respond_to do |format|
			if @team.update_attributes(team_params)
		        format.html { redirect_to(@team, :notice => 'Player was successfully updated.') }
		        format.json { respond_with_bip(@team) }
		    else
		        format.html { render :action => "show" }
		        format.json { respond_with_bip(@team) }
		   	end
		end
	end

	def destroy
		@team = Team.find(params[:id])
		raise unless Permissions.can_edit? @team

		if @team.matches.count == 0
			@team.destroy
		else
			# TODO: Alright, so here's the deal...we probably want to keep a ghost record of this team
			# what exactly that looks like I'm not sure. I think we'd remove the captain and flag the team as inactive
			# this would prevent them from being scheduled into games

			@team.captain_id = nil
			@team.active = false
			# @team.matches.future # mark each as forfeit?
			@team.save!
		end
		redirect_to root_path
	end

	# Endpoints used for handling associating players with teams
  def add_players
    @team = Team.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit? @team
    @team.players << Player.find(params[:players].select{|i| i.to_i > 0})
    redirect_to @team
  end

  def remove_players
  	@team = Team.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit? @team
  	@team.players.delete(Player.find(params[:players].select{|i| i.to_i > 0}))
  	redirect_to @team
  end

  private

  def team_params
    if @current_user.role_for_object(@team) == :admin
      params.require(:team).permit(:name, :region, :originalmmr, :dotabuff_id, :captain_id, :mmr, :active)
    else
      params.require(:team).permit(:name, :region, :originalmmr)
    end
  end

end
