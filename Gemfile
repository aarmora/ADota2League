source 'https://rubygems.org'
ruby "2.2.0"

gem 'rails', '~> 4.2'
gem 'mysql2', '> 0.3'
# gem 'execjs'
gem 'nokogiri'
gem 'rails-observers'
gem 'protected_attributes' # TODO: Remove and rework attr_accessibles
gem 'browser'

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
  gem 'therubyracer' # execjs
  gem "oink" # for doing memory analysis
  gem 'memcachier' # Old style for Heroku
  gem 'dalli' # Old style for Heroku
  gem 'redis-rails'
  gem 'slack-notifier'
  gem 'unicorn'
  gem 'rails_12factor'
  gem 'rack-cors', :require => 'rack/cors'
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

# Asset Related
gem 'uglifier', '>= 1.0.3'
gem 'select2-rails'
gem 'sass-rails'
gem 'autoprefixer-rails'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails'

# Deploy with Capistrano
gem 'capistrano',  '~> 3.1'
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-rvm'
gem 'cap-ec2'
gem 'capistrano-linked-files', git: "https://github.com/jameswilliamiii/capistrano-linked-files.git"
gem 'capistrano-unicorn-nginx'
# gem 'capistrano3-unicorn'
# gem 'sepastian-capistrano3-unicorn'


# To use debugger
# gem 'debugger'
