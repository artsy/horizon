require "console_justification"

ConsoleJustification.install(Rails.application, logger: Rails.logger) if Rails.env.production?
