require 'oink'

if Rails.env.production?
	Rails.application.middleware.use Oink::Middleware
end