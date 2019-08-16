module ProjectsHelper
  GITHUB_REMOTE_EXPR = /https:\/\/github.com\/(?<org>[^\/]+)\/(?<project>[^\.]+).git/
  STATUS_ICONS = {
    unknown: '?',
    error: '&#9888;',
    warning: '&#10071;',
    released: '&check;'
  }

  def render_log_line(project, line)
    github_match = project.ordered_stages.first&.git_remote&.match(GITHUB_REMOTE_EXPR)
    return line unless github_match
    parsed_line = ReleasecopService.parsed_log_line(line)
    link = link_to parsed_line[:sha], "https://github.com/#{github_match[:org]}/#{github_match[:project]}/commit/#{parsed_line[:sha]}"
    h(line).sub(Regexp.new(parsed_line[:sha]), link).html_safe
  end

  def project_status_icon(project)
    status = get_status(project)
    content_tag(:div, class: "project_status project_status_#{status}", title: project.snapshot&.error_message) do
      raw(STATUS_ICONS[status])
    end
  end

  def project_anchor(project)
    "project-#{project.id}"
  end

  def get_status(project)
    return :unknown if project.snapshot.nil?
    return :error if project.snapshot.error_message.present?
    return :released if project.snapshot&.comparisons&.all?(&:released?)
    :warning
  end

  def gravatar_from_log_line(line)
    email = ReleasecopService.parsed_log_line(line)[:email]
    gravatar_from_email(email)
  end

  def first_name_from_log(line)
    ReleasecopService.parsed_log_line(line)[:name].split(' ')[0]
  end

  def gravatar_from_email(email)
    return if email.blank?
    hash = Digest::MD5.hexdigest(email.downcase)
    image_tag "https://www.gravatar.com/avatar/#{hash}", class: 'avatar'
  end

  def healthy_count_class(count)
    case count
    when 0 then 'green'
    when 1..10 then 'yellow'
    else 'red'
    end
  end

  def blocked(project)
    blocks = project.deploy_blocks.unresolved.to_a
    return if blocks.empty?
    tag.div(raw('&#9888;'), class: 'blocked', title: blocks.map(&:description).to_sentence)
  end
end
