class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notify_comment.subject
  #
  def notify_comment filename
    @filename = filename
    attachments["#{filename}.csv"] = File.read(Rails.root+"public/csv/#{filename}.csv")
    mail bcc: ["isaac@turingdigital.com.tw"],
         to: ["pauline_huang@myday.com.tw"],
         cc: ["allen@myday.com.tw", "jessie_chang@myday.com.tw", "bess@turingdigital.com.tw", "dennis@turingdigital.com.tw"],
         subject: "圖靈05.My JAPAN HK 未註冊會員報表"
  end
end
