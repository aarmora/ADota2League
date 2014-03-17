class PlayersController < ApplicationController
  def index
  	show
  end
  def show
  	@current_tab = "freeagents"
  	@freeagents = Player.where("freeagentflag = :freeagent", {:freeagent => 1})  
  end

end
