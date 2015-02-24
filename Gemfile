source 'https://rubygems.org'
ruby "2.2.0"

gem 'rails', '~> 4.2'
gem 'mysql2', '> 0.3'
# gem 'execjs'
gem 'nokogiri', '1.6.6.1' # TODO: Fix for 1.6.6.2 not compiling right
gem 'rails-observers'
gem 'protected_attributes' # TODO: Remove and rework attr_accessibles

gem 'best_in_place', "~> 3.0", :git => 'git://github.com/bernat/best_in_place.git'

# use Omniauth gems for authenticating users
gem 'omniauth-steam'
gem 'omniauth-bnet'

# Misc APIS
gem 'dota', :git => 'git://github.com/nashby/dota.git'
gem 'stripe'
gem 'mandrill-api' # Email Support
gem 'icalendar' # Ical support
gem 'kappa', '~> 1.0' # Twitch API

# gem for managing environment variables (steam webapi key)
gem 'figaro'

# Bracketing solutions
gem 'challonge-api'
gem 'bracket_tree'
gem 'rubin' # round robin
gem 'rrschedule' #, git: 'https://github.com/wlangstroth/rrschedule.git'

group :development do
  gem 'tzinfo-data'
end

group :production do
  gem "exception_notification"
  gem "oink" # for doing memory analysis
  gem 'memcachier'
  gem 'dalli'
  gem 'slack-notifier'
  gem 'unicorn'
  gem 'rails_12factor'
  gem 'rack-cors', :require => 'rack/cors'
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

# Asset Related
gem 'uglifier', '>= 1.0.3'
gem "select2-rails"
gem 'sass-rails'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
