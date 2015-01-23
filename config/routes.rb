Ad2l::Application.routes.draw do

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root 'welcome#index'

  resources :seasons, :only => [:create, :update, :index, :show] do
    member do
      get 'manage' => "seasons#manage"
      get 'setup_challonge' => "challonge#setup"
      get 'sync_challonge_matches' => "challonge#sync_matches"
      get 'launch_challonge' => "challonge#launch"
      get 'rebuild_challonge' => "challonge#rebuild"
    end
  end

  resources :register

  get "schedule" => 'seasons#index'

  resources :teams do
    member do
      get 'calendar' => 'teams#calendar'
      post 'players' => 'teams#add_players'
      delete 'players'  => 'teams#remove_players'
    end
  end

  resources :team_seasons, :only => [:create, :show, :update, :destroy]
  resources :matches do
    member do
      get 'accept_reschedule' => 'matches#accept_reschedule'
    end
  end
  resources :posts
  resources :permissions
  resources :inhouses

  resources :players, :only => [:new, :index, :show, :update] do
    member do
      post 'endorse' => 'players#endorse'
    end
  end

  post 'auth/steam/callback' => 'welcome#auth_callback'
  get 'contact', :to => 'welcome#community', :as => 'contact'
  get 'community', :to => 'welcome#community', :as => 'community'
  get 'faq', :to => 'welcome#community', :as => 'faq'
  get 'logout' => 'welcome#logout'
  post 'top_plays_email' => 'welcome#top_plays_email'

  get 'matchcommentspartial' => 'matches#match_comments_partial'
  post 'matchcomment' => 'matches#create_match_comment'
  post 'matchcomment_delete' => 'matches#delete_match_comment'

  post 'add_player' => 'teams#add_player'

  #player comments
  get 'player_comments_partial' => 'players#player_comments_partial'
  post 'player_comment' => 'players#create_player_comment'
  post 'player_comment_delete' => 'players#delete_player_comment'

  scope '/admin' do
    get '/' => "admin#index"
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
