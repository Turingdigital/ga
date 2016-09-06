# Be sure to restart your server when you modify this file.

# if Rails.env.development?
Rails.application.config.session_store :cookie_store, key: '_ga_session'
# else
#   Rails.application.config.session_store :redis_session_store, {
#     key: 'session_key',
#     redis: {
#       db: 2,
#       expire_after: 120.minutes,
#       key_prefix: 'ga:session:',
#       host: ENV["REDIS_PORT_6379_TCP_ADDR"], # Redis host name, default is localhost
#       port: ENV["REDIS_PORT_6379_TCP_PORT"]   # Redis port, default is 6379
#     }
#   }
# end

# Rails.application.config.session_store :mem_cache_store
