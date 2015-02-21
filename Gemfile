source 'https://rubygems.org'
ruby "2.1.5"

gem 'rails', '~> 4.2'
gem 'rails-observers'
gem 'protected_attributes' # TODO: Remove and rework attr_accessibles

gem 'mysql2', '> 0.3'
gem 'execjs'
gem 'nokogiri', '1.6.6.1'

# use Omniauth gems for authenticating users
gem 'omniauth-steam'
gem 'omniauth-bnet'
gem 'dota', :git => 'git://github.com/nashby/dota.git'

# gem for managing environment variables (steam webapi key)
gem 'figaro'

# Bracketing solutions
gem 'challonge-api'
gem 'bracket_tree'
gem 'rubin' # round robin
gem 'rrschedule' #, git: 'https://github.com/wlangstroth/rrschedule.git'

#Twitch API
gem 'kappa', '~> 1.0'

gem 'best_in_place', "~> 3.0"

gem 'mandrill-api'

group :development do
  gem 'tzinfo-data'
# gem "httparty"
end


gem 'coffee-script-source', '1.8.0'
gem 'icalendar' # Ical support

group :production do
  gem "exception_notification"
  gem "oink" # for doing memory analysis
  gem 'memcachier'
  gem 'dalli'
  gem 'slack-notifier'
  #gem 'unicorn'
end

gem 'stripe'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

#gem select2
# remove when main gem updated
gem "select2-rails", :git => 'git://github.com/chilian/select2-rails.git'

gem 'jquery-datatables-rails', :git => 'git://github.com/rweng/jquery-datatables-rails.git'


gem 'rails_12factor', group: :production

gem 'sass-rails'
gem 'coffee-rails'
#gem 'turbo-sprockets-rails3'

# gem "less-rails"
gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git', :branch => 'bootstrap3'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '>= 1.0.3'

gem 'jquery-rails'
gem 'jquery-ui-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
