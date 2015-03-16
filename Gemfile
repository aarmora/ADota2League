source 'https://rubygems.org'
ruby "2.2.0"

gem 'rails', '~> 4.2'
gem 'mysql2', '> 0.3'
# gem 'execjs'
gem 'nokogiri'
gem 'rails-observers'
gem 'protected_attributes' # TODO: Remove and rework attr_accessibles
gem 'browser'
gem 'paperclip'

gem 'best_in_place', "~> 3.0", :git => 'git://github.com/bernat/best_in_place.git'

# use Omniauth gems for authenticating users
gem 'omniauth-steam'
gem 'omniauth-bnet'
gem 'omniauth-twitter'

# WYSIWYG
gem 'summernote-rails'
gem 'font-awesome-rails' # required???

# Misc APIS
gem 'twitter'
gem 'dota', :git => 'git://github.com/nashby/dota.git'
gem 'stripe'
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
  gem 'coffee-script-source', '1.8.0' #Windows doesn't like CS 1.9
end

#Trying to debug slack notifications
#gem 'exception_notification', :git => 'https://github.com/smartinez87/exception_notification.git'
#gem 'slack-notifier'#, :git => 'git://github.com/rails/exception_notification.git'

group :production do
  gem "exception_notification"#, :git => 'https://github.com/smartinez87/exception_notification.git'
  #gem 'slack-notifier'
  gem 'therubyracer' # execjs
  gem "oink" # for doing memory analysis
  gem 'memcachier' # Old style for Heroku
  gem 'dalli' # Old style for Heroku
  gem 'aws-sdk', '< 2.0'
  gem 'mandrill-api'
  gem 'redis-rails'
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
