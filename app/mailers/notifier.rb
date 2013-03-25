class Notifier < ActionMailer::Base
  Server = Rails.env.development? ? '127.0.0.1:3000' : '<anonymized>'
  Admins = %w(<anonymized>@gmail.com <anonymized>@gmail.com)
  default :from => "<anonymized>@gmail.com"

  def test_email
    mail(:to => 'kapelner@gmail.com', :subject => "You have a new friend!")
    body 'body of email'
  end

end
