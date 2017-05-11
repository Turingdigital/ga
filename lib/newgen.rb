class Newgen < Analytics
  def newgen_1(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventLabel=~進一步洽詢|回到首頁|左上方和運LOGO" #ga:eventCategory==按鈕;ga:eventAction==電腦版點擊;
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def newgen_2(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:sessions ga:bounceRate )

    dimensions = %w( ga:sourceMedium )
    sort = %w(-ga:sessions)
    filters = "ga:deviceCategory==desktop" #"ga:eventLabel=~進一步洽詢|回到首頁|左上方和運LOGO" #ga:eventCategory==按鈕;ga:eventAction==電腦版點擊;
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def newgen_2_pre2(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:sessions )

    dimensions = %w( ga:sourceMedium )
    sort = nil # %w(-ga:sessions)
    filters = "ga:deviceCategory==desktop" #"ga:eventLabel=~進一步洽詢|回到首頁|左上方和運LOGO" #ga:eventCategory==按鈕;ga:eventAction==電腦版點擊;
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def newgen_3(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:sourceMedium )
    sort = nil # %w(-ga:sessions)
    filters = "ga:eventLabel==進一步洽詢;ga:deviceCategory==desktop" #ga:eventCategory==按鈕;ga:eventAction==電腦版點擊;
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def newgen_4(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:sessions ga:bounceRate )

    dimensions = %w( ga:sourceMedium )
    sort = %w(-ga:sessions)
    filters = "ga:deviceCategory!=desktop" #"ga:eventLabel=~進一步洽詢|回到首頁|左上方和運LOGO" #ga:eventCategory==按鈕;ga:eventAction==電腦版點擊;
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def newgen_4_pre2(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:sessions )

    dimensions = %w( ga:sourceMedium )
    sort = nil # %w(-ga:sessions)
    filters = "ga:deviceCategory==desktop" #"ga:eventLabel=~進一步洽詢|回到首頁|左上方和運LOGO" #ga:eventCategory==按鈕;ga:eventAction==電腦版點擊;
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def newgen_5(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:sourceMedium )
    sort = nil # %w(-ga:sessions)
    filters = "ga:eventLabel==進一步洽詢;ga:deviceCategory!=desktop" #ga:eventCategory==按鈕;ga:eventAction==電腦版點擊;
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end
end
