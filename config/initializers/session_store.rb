# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_ga_session'
# Rails.application.config.session_store :mem_cache_store
Rails.application.config.session_store :redis_session_store, {
  key: 'session_key',
  redis: {
    db: 2,
    expire_after: 120.minutes,
    key_prefix: 'ga:session:',
    host: 'localhost', # Redis host name, default is localhost
    port: 6379   # Redis port, default is 6379
  }
}
