module ProjectsHelper
  LOG_LINE_EXPR = /^(?<sha>[0-9a-f]+) (?<date>[0-9\-]+) (?<message>.*) \((?<name>.*), (?<email>.*)\)\w*$/ # %h %ad %s (%an, %ae)
  GITHUB_REMOTE_EXPR = /https:\/\/github.com\/(?<org>[^\/]+)\/(?<project>[^\.]+).git/
  STATUS_ICONS = {
    unknown: '?',
    warning: '&#10071;',
    released: '&check;'
  }

  def render_log_line(project, line)
    github_match = project.stages.ordered.first&.git_remote&.match(GITHUB_REMOTE_EXPR)
    return line unless github_match
    line_match = line.match(LOG_LINE_EXPR)
    link = link_to line_match[:sha], "https://github.com/#{github_match[:org]}/#{github_match[:project]}/commit/#{line_match[:sha]}"
    h(line).sub(Regexp.new(line_match[:sha]), link).html_safe
  end

  def project_status_icon(project)
    status = get_status(project)
    content_tag(:div, class: "project_status project_status_#{status}") do
      raw(STATUS_ICONS[status])
    end
  end

  def project_anchor(project)
    "project-#{project.id}"
  end

  def get_status(project)
    return :unknown if project.snapshot.nil?
    return :released if project.snapshot&.comparisons&.all?(&:released?)
    :warning
  end

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
