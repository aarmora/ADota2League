Ad2l::Application.routes.draw do

  # This line mounts Forem's routes at /forums by default.
  # This means, any requests to the /forums URL of your application will go to Forem::ForumsController#index.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Forem relies on it being the default of "forem"
  mount Forem::Engine, :at => '/forums'


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root 'welcome#index'

  resources :seasons, :only => [:create, :update, :destroy, :index, :show] do
    member do
      get 'manage' => "seasons#manage"

      get 'playoffs' => "seasons#playoffs"
      post 'playoffs' => "seasons#create_playoffs"
      get 'start_playoffs' => "seasons#start_playoffs"
      get 'reset_playoffs' => "seasons#reset_playoffs"

      get 'setup_challonge' => "challonge#setup"
      get 'sync_challonge_matches' => "challonge#sync_matches"
      get 'launch_challonge' => "challonge#launch"
      get 'rebuild_challonge' => "challonge#rebuild"
    end
  end

  get 'register' =>  'register#new'
  get 'tweet_and_follow' => 'register#tweet_and_follow'

  get "schedule" => 'seasons#index'

  resources :teams do
    member do
      get 'calendar' => 'teams#calendar'
      post 'players' => 'teams#add_players'
      delete 'players'  => 'teams#remove_players'
    end
  end

  resources :team_seasons, :only => [:create, :show, :update, :destroy] do
    member do
      get 'paypal' => 'team_seasons#paypal'
      get 'paypal_success' => 'team_seasons#paypal_callback_success'
      get 'paypal_error' => 'team_seasons#paypal_callback_error'
    end
  end

  resources :matches do
    member do
      get 'accept_reschedule' => 'matches#accept_reschedule'
    end
  end
  resources :posts
  resources :permissions
  resources :inhouses

  resources :players, :only => [:new, :show, :update] do
    member do
      post 'endorse' => 'players#endorse'
    end
  end

  get 'search/typeahead' => 'search#typeahead'

  post 'auth/steam/callback' => 'authentication#steam_callback'
  get 'auth/bnet/callback' => 'authentication#bnet_callback'
  get 'auth/twitter/callback' => 'authentication#twitter_callback'
  get 'logout' => 'authentication#logout'

  get 'contact', :to => 'welcome#community', :as => 'contact'
  get 'community', :to => 'welcome#community', :as => 'community'
  get 'faq', :to => 'welcome#community', :as => 'faq'
  get 'reg_form_partial' => 'register#reg_form_partial'
  post 'register_caster' => "players#register_caster"
  get 'welcome/get_posts' => 'welcome#get_posts'
  post 'top_plays_email' => 'welcome#top_plays_email'


  get 'matchcommentspartial' => 'matches#match_comments_partial'
  post 'matchcomment' => 'matches#create_match_comment'
  post 'matchcomment_delete' => 'matches#delete_match_comment'

  post 'add_player' => 'teams#add_player'

  get 'no_emails' => "players#no_emails"

  #player comments
  get 'player_comments_partial' => 'players#player_comments_partial'
  post 'player_comment' => 'players#create_player_comment'
  post 'player_comment_delete' => 'players#delete_player_comment'

  scope '/admin' do
    get '/' => "admin#index", :as => "admin_index"
    get 'teams' => 'admin#teams', :as => "admin_teams"
    get 'players' => 'admin#players', :as => "admin_players"
    get "manage_seasons(/:season(/:week))" => 'admin#manage_seasons'
  end

  # Legacy routes for old deep links
  get '/Schedule.asp' => redirect('/schedule')
  get '/community.asp' => redirect('/community')
  get '/Index.asp' => redirect('/')

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
