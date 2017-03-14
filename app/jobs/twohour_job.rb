class TwohourJob < ActiveJob::Base
  queue_as :default

  def perform(*args)#(url_builder)
    # Do something later
    url_builder = args.first
    profile_id = url_builder.user.account_summary.default_profile
    # sleep(60*60*2)
    analytics = Analytics.new url_builder.user
    result = analytics.get_sessions_filter_canpaign_today(
          profile_id,
          url_builder.source,
          url_builder.campaign_medium.medium,
          url_builder.content,
          url_builder.name,
          url_builder.term)
    url_builder.twohour = result["totals_for_all_results"]["ga:sessions"]
    url_builder.save
  end
end
