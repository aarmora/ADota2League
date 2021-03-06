# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

set :nginx_server_name, 'beta.amateurdota2league.com amateurdota2league.com www.amateurdota2league.com dota.playon.gg dota.playongg.com'
set :slack_webhook, "https://hooks.slack.com/services/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"

ec2_role :web,
  ssh_options: {
    user: 'ubuntu', # overrides user setting above
    keys: [File.join(Dir.pwd, "./config/playon.pem")]
  }

ec2_role :app,
  ssh_options: {
    user: 'ubuntu', # overrides user setting above
    keys: [File.join(Dir.pwd, "./config/playon.pem")]
  }

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
