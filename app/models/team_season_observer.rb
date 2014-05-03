class TeamSeasonObserver < ActiveRecord::Observer
  def after_save(ts)
    # This will reset the season page associated with this entry
    controller = ActionController::Base.new
    controller.expire_fragment("seasonPage-" + ts.season_id.to_s) unless ts.season_id.nil?
  end
end
