class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notify_comment.subject
  #
  def notify_comment filename, date_str
    @filename = filename
    attachments["#{filename}.csv"] = File.read(Rails.root+"public/csv/#{filename}.csv")
    mail bcc: ["isaac@turingdigital.com.tw"],
         to: ["pauline_huang@myday.com.tw"],
         cc: ["allen@myday.com.tw", "jessie_chang@myday.com.tw", "bess@turingdigital.com.tw", "dennis@turingdigital.com.tw"],
         subject: "#{date_str} 圖靈05. MYJAPAN HK未註冊會員報表"
  end

  def myday_b01 filename, date_str
    @filename = filename
    attachments["#{filename}.xls"] = File.read(Rails.root+"public/csv/#{filename}.xls")
    mail bcc: ["isaac@turingdigital.com.tw"],
         to: ["bess@turingdigital.com.tw"],
         # to: ["pauline_huang@myday.com.tw"],
         # cc: ["allen@myday.com.tw", "jessie_chang@myday.com.tw", "bess@turingdigital.com.tw", "dennis@turingdigital.com.tw"],
         subject: "圖靈#{date_str}-MYDAY未註冊會員報表"
  end

  def stainan filename
    @filename = filename
    attachments["#{filename}.xls"] = File.read(Rails.root+"public/csv/#{filename}.xls")
    mail bcc: ["isaac@turingdigital.com.tw"],
         to: ["allen.chen@wwplus.com.tw"],
         cc: ["bess@turingdigital.com.tw", "dennis@turingdigital.com.tw"],
         subject: "圖靈01.妳好南搞滾軸事件報表"
  end
end
