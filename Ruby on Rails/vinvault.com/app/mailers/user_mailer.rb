class UserMailer < ActionMailer::Base
  default from: ENV['CONTACT_EMAIL']

  def welcome_email(user)
    @user = user
    @url  = "http://#{ENV['SITE_DOMAIN']}/users/sign_in"
    mail(to: @user.email, subject: "Welcome to #{ENV['SITE_NAME']}")
  end

  def cancellation_email(user)
    @user = user
    @url  = "http://#{ENV['SITE_DOMAIN']}/plans"
    mail(to: @user.email, subject: "Your subscription to #{ENV['SITE_NAME']} has been cancelled.")
  end

  def trial_ending_email(user)
    @user = user
    @url = "http://#{ENV['SITE_DOMAIN']}/users/sign_in"
    mail(to: @user.email, subject: "Your trial to #{ENV['SITE_NAME']} is ending.")
  end

end
