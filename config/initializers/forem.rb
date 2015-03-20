Forem.user_class = "Player"
Forem.email_from_address = "amateurdota2league@gmail.com"
# If you do not want to use gravatar for avatars then specify the method to use here:
Forem.avatar_user_method = :avatar
Forem.per_page = 20

Forem.sign_in_path = "/auth/steam"

Rails.application.config.to_prepare do
  # If you want to change the layout that Forem uses, uncomment and customize the next line:
  #Forem::ApplicationController.layout "no_chrome"
  Forem::ApplicationController.layout "application"

  # If you want to add your own cancan Abilities to Forem, uncomment and customize the next line:
  # Forem::Ability.register_ability(Ability)
end

#
# By default, these lines will use the layout located at app/views/layouts/forem.html.erb in your application.
