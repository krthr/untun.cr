require "log"
require "./untun/**"

module Untun
  # :nodoc:
  Log = ::Log.for(
    self,
    level: ENV["LOG_LEVEL"]?.try { |v| ::Log::Severity.parse(v) } || ::Log::Severity::Info
  )

  VERSION = "0.1.0"
end
