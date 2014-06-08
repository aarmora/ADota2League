class PermissionsController < ApplicationController
  before_filter :verify_admin
  before_filter :check_permission_access, :unless => Permissions.user_is_site_admin?

	def create
    @permission = Permission.new
    @permission.attributes = params[:permission]
    @permission.save!

    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
    
	end


  def update
    @permission = Permission.find(params[:id])

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

    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
  end

  def check_permission_access
    # Verify that we can actually create this specific permission

    if params[:id] && !params[:permission] # delete
      @permission = Permission.find(params[:id])
      mode = @permission.permission_mode
      season_id = @permission.season_id
    else # new / update
      mode = params[:permission][:permission_mode]
      season_id = params[:permission][:season_id]
    end

    valid = false
    if Permissions.user_is_site_admin?
      valid = true
    elsif (!@permission && mode == "season") || mode == "division" # Deleting requires site admin
      valid = Permissions.permissions_for_user.any? {|p| p.permission_mode == "season" && p.season_id == season_id}
    end
    raise "Illegal Permission Access" unless valid
  end

end
