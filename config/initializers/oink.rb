if Rails.env.production?
  require 'oink'
	Rails.application.middleware.use(Oink::Middleware, :logger => Hodel3000CompliantLogger.new(STDOUT))
end