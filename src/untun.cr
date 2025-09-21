require "log"
require "./untun/**"

module Untun
  # :nodoc:
  Log = ::Log.for(
    self,
    level: ENV["LOG_LEVEL"]?.try { |v| ::Log::Severity.parse(v) } || ::Log::Severity::Info
  )

  VERSION = {{ `shards version #{__DIR__}`.strip.stringify }}
end
