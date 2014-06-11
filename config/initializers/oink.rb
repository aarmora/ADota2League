require 'oink'

if Rails.env.production?
	Rails.application.middleware.use(Oink::Middleware, :logger => Hodel3000CompliantLogger.new(STDOUT))
end