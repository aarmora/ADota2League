class RegisterController < ApplicationController
	def new
		if !@current_user
			render "register/logged_out"
		else
			@player = @current_user
	    @open_seasons = Season.where(:registration_open => true)
		  @current_tab = "register"

      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = session[:current_user][:twitter][:auth_token]
        config.access_token_secret = session[:current_user][:twitter][:auth_secret]
      end

      puts twitter_client.friendship?(twitter_client.user, "Adota2l").inspect
      puts twitter_client.user_timeline(twitter_client.user.id, {exclude_replies: true, include_rts: false}).first.inspect
		end
	end
end
