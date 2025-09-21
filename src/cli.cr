require "option_parser"
require "./untun.cr"

url = nil
port = 3000
hostname = "localhost"
protocol = "http"

option_parser = OptionParser.parse do |parser|
  parser.banner = "
  untun.cr
  Tunnel your local HTTP(s) server to the world! Powered by Cloudflare Quick Tunnels.
  "

  parser.on "-v", "--version", "Show version" do
    puts Untun::VERSION
    exit
  end

  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end

  parser.on "-u", "--url=URL", "The URL of the tunnel" do |val|
    url = val
  end

  parser.on "-p", "--port=PORT", "The port of the tunnel (default: 3000)" do |val|
    port = val.to_i32
  end

  parser.on "--hostname=localhost|example.com", "The hostname of the tunnel (default: localhost)" do |val|
    hostname = val
  end

  parser.on "--protocol=http|https", "The protocol of the tunnel (default: http)" do |val|
    protocol = val
  end
end

tunnel = Untun.start_tunnel(
  url,
  port: port,
  hostname: hostname,
  protocol: protocol
)

if !tunnel
  Untun::Log.fatal { "Tunnel not started." }
  exit(1)
end

# Get URL (blocks until available)
spawn do
  Untun::Log.info { "Waiting for tunnel URL..." }

  tunnel_url = tunnel.url.receive
  Untun::Log.info { "Tunnel ready at #{tunnel_url}" }
end

# Handle signals gracefully
Signal::INT.trap do
  Untun::Log.info { "Shutting down tunnel..." }
  tunnel.stop
  exit(0)
end

Signal::TERM.trap do
  tunnel.stop
  exit(0)
end

# Keep the process running
sleep
