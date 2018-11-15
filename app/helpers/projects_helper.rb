module ProjectsHelper
  def gravatar_from_log_line(line)
    gravatar_from_email(email_from_log_line(line))
  end

  def email_from_log_line(line)
    line.match(/, ([^ ]*)\)$/)&.[](1)
  end

  def gravatar_from_email(email)
    return if email.blank?
    hash = Digest::MD5.hexdigest(email.downcase)
    image_tag "https://www.gravatar.com/avatar/#{hash}", class: 'avatar'
  end
end
