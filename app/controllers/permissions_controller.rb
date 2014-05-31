class PermissionsController < ApplicationController
	def create
	    @player_permission = Permission.new
	    @player_permission.attributes = params[:permission]
	    @player_permission.save!

	    redirect_to(@player_permission.player)
	end


  def update
    @permission = Permission.find(params[:id])
    respond_to do |format|
      if @permission.update_attributes(params[:permission])
        format.html { redirect_to(@permission.player, :notice => 'Player was successfully updated.') }
        format.json { respond_with_bip(@permission.player) }
      else
        format.html { render :action => "show" }
        format.json { respond_with_bip(@permission.player) }
      end
    end
  end

end
