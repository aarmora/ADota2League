class PermissionsController < ApplicationController
	def create
	    @permission = Permission.new
	    @permission.attributes = params[:permission]
	    @permission.save!

      if @permission.player.nil?
        redirect_to manage_season_path(@permission.season)
      else
	      redirect_to(@permission.player)
      end
	end


  def update
    @permission = Permission.find(params[:id])
    # TODO: create some protection here to make sure the permissions beind added are below the person setting them
    respond_to do |format|
      if @permission.update_attributes(params[:permission])
        format.html { redirect_to(@permission.player, :notice => 'Player was successfully updated.') }
        format.json { respond_with_bip(@permission) }
      else
        format.html { render :action => "show" }
        format.json { respond_with_bip(@permission) }
      end
    end
  end

  def destroy
    @permission = Permission.find(params[:id])
    @player = @permission.player
    @permission.destroy

    redirect_to @player
  end

end
