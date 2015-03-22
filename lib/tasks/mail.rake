namespace :mail do

  notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
  notifier.channel = '#ad2l_exceptions'

  desc "Remind teams that late fee is coming.  Scheduled task"  
  task :signup_reminder => :environment do

  	begin
	  	@active_seasons = Season.where(:active => true)
	  	@active_seasons.each do |season|
	  		unless season.late_fee_start.nil?
	  			days_until_late_fee = ((season.late_fee_start - Time.now) / 1.day).to_i
		  		if (days_until_late_fee) > 2
			  		@team_seasons = season.team_seasons.where(:paid => false)
			  		@team_seasons.each do |ts|			  			
			  			unless ts.participant.captain.email.nil? || ts.participant.captain.receive_emails = false
        				participant.unsubscribe_key = "ad2l" + rand(100000).to_s
        				participant.save!
					      UserMailer.signup_reminder(ts.participant.captain, season, ts, days_until_late_fee).deliver	
					    end
			  		end
			  	end
		  	end
	  	end
  		
  	rescue Exception => e
  		#notifier.ping "signup_reminder #{e}"#, icon_url: "http://icons.iconarchive.com/icons/chrisbanks2/cold-fusion-hd/128/paypal-icon.png"
  	
  		puts "Failed with #{e}, #{e.backtrace}"  	
  	end

  end

	desc "Send email"
  task :mail => :environment do

  	begin
	    @players = Player.where(:receive_emails => true)
	    playerz = Player.find(205)
	    @players.each do |player|
	      unless player.email.nil?
	        player.unsubscribe_key = "ad2l" + rand(100000).to_s
	        player.save!
	        UserMailer.season4_reminder(player, playerz).deliver
	        #UserMailer.season4_reminder(playerz, playerz).deliver
	      end
	    end
  	rescue Exception => e
  		#notifier.ping "signup_reminder #{e}"#, icon_url: "http://icons.iconarchive.com/icons/chrisbanks2/cold-fusion-hd/128/paypal-icon.png"
  	
  		puts "Failed with #{e}, #{e.backtrace}"  	
  	end
  end

end