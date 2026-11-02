require "json"
require "socket"
require "time"

# Requires a justification before a sensitive Rails console session starts, and records it as a structured log line. Deliberately uncoupled from app so it can be extracted as a gem.
#
#   ConsoleJustification.install(Rails.application, logger: Rails.logger) if Rails.env.production?
module ConsoleJustification
  EVENT = "console_session_started"

  class Aborted < StandardError; end

  module_function

  def install(app, logger:)
    app.console { start(logger: logger) }
  end

  # Prompts (or reads CONSOLE_JUSTIFICATION / CONSOLE_USER for non-interactive
  # `run` invocations), logs, and aborts the console when either is blank.
  def start(logger:, input: $stdin, output: $stderr, env: ENV)
    user = env["CONSOLE_USER"] || ask("Your email", input, output)
    reason = env["CONSOLE_JUSTIFICATION"] || ask("Justification for this console", input, output)
    raise Aborted, "A user and justification are required to start this console." if user.empty? || reason.empty?

    logger.warn({event: EVENT, user: user, justification: reason, host: Socket.gethostname, pid: Process.pid, at: Time.now}.to_json)
  rescue Aborted => e
    output.puts e.message
    exit 1
  end

  def ask(question, input, output)
    return "" unless input.tty?
    output.print "#{question}: "
    input.gets.to_s.strip
  end
end
