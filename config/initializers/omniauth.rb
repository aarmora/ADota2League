require "openid/fetchers"
require "openid/store/filesystem"

OpenID.fetcher.ca_file  = "#{Rails.root}/config/certs/cacert.pem"
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :steam, ENV["STEAM_WEB_API_KEY"], :store => OpenID::Store::Filesystem.new('./tmp')
  provider :bnet, ENV['BNET_KEY'], ENV['BNET_SECRET'], scope: "sc2.profile", :store => OpenID::Store::Filesystem.new('./tmp') if Rails.env.development?
end