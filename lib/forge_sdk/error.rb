# frozen_string_literal: true

module ForgeSdk
  # Base error for the Forge SDK.
  class ForgeError < StandardError; end

  # The server returned a 4xx/5xx response.
  class ServerError < ForgeError
    attr_reader :status_code

    def initialize(status_code, message)
      @status_code = status_code
      super("server error (#{status_code}): #{message}")
    end
  end

  # Failed to connect to the Forge server.
  class ConnectionError < ForgeError
    def initialize(cause)
      super("connection error: #{cause.message}")
    end
  end
end
