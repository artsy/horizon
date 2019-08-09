class ReleasecopService
  LOG_LINE_EXPR = /^(?<sha>[0-9a-f]+) (?<date>[0-9\-]+) (?<message>.*) \((?<name>.*), (?<email>.*)\)\w*$/ # %h %ad %s (%an, %ae)

  def self.parsed_log_line(line)
    line.match(LOG_LINE_EXPR)&.named_captures || {}
  end
end
