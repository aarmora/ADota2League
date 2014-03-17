class PlayersController < ApplicationController
  def index
  	@current_tab = "freeagents"
    @freeagents = Player.where("freeagentflag = :freeagent", {:freeagent => 1})
  end
end
