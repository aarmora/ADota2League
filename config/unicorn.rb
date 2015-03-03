# config/unicorn.rb

# Set the current app's path for later reference. Rails.root isn't available at
# this point, so we have to point up a directory.
app_path = File.expand_path(File.dirname(__FILE__) + '/..')

worker_processes (ENV['RAILS_ENV'] == 'production' ? ENV["WEB_CONCURRENCY"] || 2 : 2)

listen app_path + '/tmp/unicorn.sock', backlog: 64
listen(3000, backlog: 64) if ENV['RAILS_ENV'] == 'development'

# Set the working directory of this unicorn instance.
working_directory app_path
# TODO: set to a shared folder so these are easier to track down
stderr_path app_path + '/log/unicorn.log'
stdout_path app_path + '/log/unicorn.log'
pid app_path + '/tmp/unicorn.pid'
timeout 15
preload_app true

user 'ubuntu', 'ubuntu' unless ENV['RAILS_ENV'] == 'development'
rails_env = ENV['RAILS_ENV'] || 'production'

# Garbage collection settings.
GC.respond_to?(:copy_on_write_friendly=) &&
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end