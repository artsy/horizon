require "rails_helper"

describe ConsoleJustification do
  let(:logger) { instance_double(Logger, warn: nil) }
  let(:output) { StringIO.new }

  def tty_input(*lines)
    StringIO.new(lines.join("\n") + "\n").tap { |io| allow(io).to receive(:tty?).and_return(true) }
  end

  it "logs the user and justification" do
    described_class.start(logger: logger, input: tty_input("a@artsy.net", "debugging #123"), output: output, env: {})
    expect(logger).to have_received(:warn) do |line|
      expect(JSON.parse(line)).to include("event" => "console_session_started", "user" => "a@artsy.net", "justification" => "debugging #123")
    end
  end

  it "accepts values from the environment for non-interactive runs" do
    described_class.start(logger: logger, input: StringIO.new, output: output, env: {"CONSOLE_USER" => "a@artsy.net", "CONSOLE_JUSTIFICATION" => "task"})
    expect(logger).to have_received(:warn)
  end

  it "aborts without logging when the justification is blank" do
    expect {
      described_class.start(logger: logger, input: tty_input("a@artsy.net", ""), output: output, env: {})
    }.to raise_error(SystemExit)
    expect(logger).not_to have_received(:warn)
  end

  it "aborts when there is no tty and no env values" do
    expect { described_class.start(logger: logger, input: StringIO.new, output: output, env: {}) }.to raise_error(SystemExit)
  end
end
