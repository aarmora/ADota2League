class UserMailer < ActionMailer::Base
  default from: "amateurdota2league@gmail.com"

   def match_comment_email(match_id)
    @user = Player.find(205)
    @url  = 'http://amateurdota2league.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
