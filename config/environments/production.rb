Ad2l::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.eager_load = true
  config.log_level = :info

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = true

  # Compress JavaScripts and CSS
  config.assets.compress = true
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  config.cache_store = :dalli_store
  # config.cache_store = :redis_store, 'redis://localhost:6379/0/cache'

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = "http://d2oiplpb7rk92t.cloudfront.net"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  #config.action_mailer.default_url_options = { :host => 'amateurdota2league.com' }

  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
      bucket: ENV['AWS_S3_BUCKET'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    },
    s3_storage_class: :reduced_redundancy,
    url: ':s3_domain_url'
  }

  ActionMailer::Base.smtp_settings = {
    :address        => "smtp.mandrillapp.com",
    :port           => "587",
    :authentication => 'plain',
    :user_name      => ENV["MANDRILL_USERNAME"],
    :password       => ENV["MANDRILL_API_KEY"]
  }
  config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[AD2L Site] ",
      :sender_address => %{"AD2L Bug Notifier" <amateurdota2league@gmail.com>},
      :exception_recipients => %w{charlie.croom@gmail.com, jbhansen84@gmail.com, amateurdota2league@gmail.com},
      :normalize_subject => true
    },
    :slack => {
     :webhook_url => "[https://hooks.slack.com/services/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]",
     :channel => "#ad2l_exceptions"
    }

  # Configure CORS headers for all requests so that the caching server serves them with CORS headers
  config.middleware.insert_before 0, Rack::Cors, :logger => (-> { Rails.logger }) do
    allow do
      origins 'amateurdota2league.com', 'www.amateurdota2league.com'
      resource '*', :headers => :any, :methods => [:get, :options]
    end
  end

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
