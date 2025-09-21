module Untun::Cloudflared
  extend self

  URL_REGEX = /\|\s+(https?:\/\/\S+)/

  alias TunnelStartOptions = Hash(String, String | Int32 | Nil)

  record Connection, id : String, ip : String, location : String

  class TunnelResult
    getter url : Channel(String)
    getter process : Process

    def initialize(@process : Process, @url : Channel(String)); end

    def stop
      @process.terminate
    end
  end

  def start_cloudflared_tunnel(options : TunnelStartOptions) : TunnelResult
    args = build_tunnel_args(options)
    command = CLOUDFLARED_BIN_PATH.to_s

    Log.debug { "Starting #{command} with args: #{args}" }

    process = Process.new(
      command,
      args: args,
      input: Process::Redirect::Close,
      output: Process::Redirect::Pipe,
      error: Process::Redirect::Pipe,
    )

    # Create channel for URL detection
    url_channel = Channel(String).new(1)

    # Start output parsers
    spawn { parse_output(process.output, url_channel) }
    spawn { parse_output(process.error, url_channel) }

    TunnelResult.new(process: process, url: url_channel)
  rescue ex
    raise "Failed to start cloudflared: #{ex.message}"
  end

  private def build_tunnel_args(options : TunnelStartOptions) : Array(String)
    args = ["tunnel"]

    options.each do |key, value|
      args << key
      args << value.to_s if value
    end

    # Default to localhost:8080 if no options provided
    args.concat(["--url", "localhost:8080"]) if args.size == 1

    args
  end

  private def parse_output(io : IO, url_channel : Channel(String)) : Nil
    io.each_line do |line|
      Log.debug { line }

      # Extract tunnel URL when it appears
      if match = line.match(URL_REGEX)
        begin
          url_channel.send(match[1])
        rescue Channel::ClosedError
          # Channel already has URL, ignore
        end
      end
    end
  rescue ex : IO::Error
    # Process terminated, IO closed
    Log.debug { "Output stream closed" }
  rescue ex
    Log.error(exception: ex) { "Error parsing cloudflared output" }
  ensure
    url_channel.close
  end
end
