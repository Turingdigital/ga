class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notify_comment.subject
  #
  def notify_comment filename
    @greeting = "Hi"
    attachments["#{filename}.csv"] = File.read(Rails.root+"public/csv/#{filename}.csv")
    mail to: ["bess@turingdigital.com.tw"],
         cc: ["wenchibaw@turingdigital.com.tw"]
         bcc: ["isaac@turingdigital.com.tw"]
         subject: "#{filename} 未註冊會員報表"
  end
end
