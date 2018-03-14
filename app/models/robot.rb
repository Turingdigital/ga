class Robot < ActiveRecord::Base
  def url
    target = URI::encode(self.target)
    myUri = URI.parse target
    dh = myUri.host
    dp = myUri.path
    dt = self.title
    #  &cs=google&cm=banner
    cs = self.cs
    cm = self.cm
    cn = self.cn
    tid = self.tid

    dl = URI::encode(target)

    cid = "#{rand(10**9)}.#{rand(10**10)}"
    # url = "https://www.google-analytics.com/collect?v=1&tid=#{tid}&cid=#{cid}&t=pageview&cs=#{cs}&cm=#{cm}&cn=#{cn}&dh=#{dh}&dp=#{dp}&dt=#{dt}&dl=#{dl}&ul=#{robot.ul}&geoid=#{robot.geoid}&sr=#{robot.sr}&vp=#{robot.vp}&ua=#{robot.ua}&sd=32-bits&fl=23.0 r0"
    url = "https://www.google-analytics.com/collect?v=1"
    url += "&tid=#{tid}" if !tid.empty? && !tid.nil?
    url += "&cid=#{cid}" if !cid.empty? && !cid.nil?
    url +=  "&t=pageview"
    url += "&cs=#{cs}" if !cs.empty? && !cs.nil?
    url += "&cm=#{cm}" if !cm.empty? && !cm.nil?
    url += "&cn=#{cn}" if !cn.empty? && !cn.nil?
    url += "&dh=#{dh}" if !dh.empty? && !dh.nil?
    url += "&dp=#{dp}" if !dp.empty? && !dp.nil?
    url += "&dt=#{dt}" if !dt.empty? && !dt.nil?
    url += "&dl=#{dl}" if !dl.empty? && !dl.nil?
    url += "&ul=#{self.ul}" if !self.ul.empty? && !self.ul.nil?
    url += "&geoid=#{self.geoid}" if !self.geoid.empty? && !self.geoid.nil?
    url += "&sr=#{self.sr}" if !self.sr.empty? && !self.sr.nil?
    url += "&vp=#{self.vp}" if !self.vp.empty? && !self.vp.nil?
    url += "&ua=#{self.ua}" if !self.ua.empty? && !self.ua.nil?
    url += "&sd=32-bits&fl=23.0 r0"
    url = URI::encode(url)

    return url
  end
end
