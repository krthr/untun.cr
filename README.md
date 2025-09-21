# untun

🚇 Tunnel your local HTTP(s) server to the world! Powered by 🔥 Cloudflare Quick Tunnels.

A Crystal port of [unjs/untun](https://github.com/unjs/untun).

## Overview

`untun` allows you to expose your local HTTP(s) server to the internet using Cloudflare's free Quick Tunnels service. No account required!

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/krthr/untun
   cd untun
   ```

2. Build the project:
   ```bash
   shards build --release
   ```

3. The binary will be available at `./bin/untun`

### As a Dependency

Add this to your application's `shard.yml`:

```yaml
dependencies:
  untun:
    github: krthr/untun
```

## Usage

### CLI

Start a tunnel to your local server:

```bash
# Tunnel a local server running on port 3000 (default)
./bin/untun

# Tunnel a specific port
./bin/untun --port 8080

# Tunnel a specific URL
./bin/untun --url http://localhost:4000

# Tunnel with HTTPS
./bin/untun --protocol https --port 443

# Show help
./bin/untun --help
```

### Programmatic Usage

```crystal
require "untun"

# Start a tunnel with default settings
tunnel = Untun.start_tunnel

# Start a tunnel with custom settings
tunnel = Untun.start_tunnel(
  port: 8080,
  hostname: "localhost",
  protocol: "http",
  accept_cloudflare_notice: true
)

if tunnel
  # Get the public URL (blocks until ready)
  spawn do
    url = tunnel.url.receive
    puts "Tunnel ready at: #{url}"
  end
  
  # Keep the tunnel running
  sleep
  
  # Or stop it manually
  tunnel.stop
end
```

## Options

### CLI Options

- `-u, --url URL` - The URL to tunnel (overrides port/hostname/protocol)
- `-p, --port PORT` - The port to tunnel (default: 3000)
- `--hostname HOST` - The hostname to tunnel (default: localhost)
- `--protocol PROTO` - The protocol to use: http or https (default: http)
- `-v, --version` - Show version
- `-h, --help` - Show help

### Environment Variables

- `UNTUN_ACCEPT_CLOUDFLARE_NOTICE` - Set to any value to automatically accept Cloudflare's terms
- `LOG_LEVEL` - Set the log level (e.g., DEBUG, INFO, WARN, ERROR)
- `CLOUDFLARED_VERSION` - Override the cloudflared version to download

## Features

- 🚀 **Zero Configuration** - Just run and get a public URL
- 🔒 **Secure** - All tunnels use HTTPS on the public side
- 📦 **Self-contained** - Automatically downloads cloudflared binary if needed
- 🛑 **Graceful Shutdown** - Handles Ctrl+C and cleanup properly
- 🔧 **Flexible** - Use via CLI or as a library in your Crystal application

## How It Works

`untun` uses Cloudflare's Quick Tunnels feature through the `cloudflared` binary. When you start a tunnel:

1. It checks if `cloudflared` is installed, and downloads it if necessary
2. Starts the tunnel process pointing to your local server
3. Extracts and returns the public HTTPS URL
4. Keeps the tunnel running until you stop it

## Development

1. Clone the repository
2. Install dependencies:
   ```bash
   shards install
   ```
3. Run tests:
   ```bash
   crystal spec
   ```
4. Build for development:
   ```bash
   shards build
   ```

## Contributing

1. Fork it (<https://github.com/krthr/untun/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Acknowledgments

This is a Crystal port of the excellent [unjs/untun](https://github.com/unjs/untun) project. All credit for the concept goes to the original authors.

## License

MIT License - see [LICENSE](LICENSE) for details.

**Note:** Your use of the cloudflared binary is subject to the [Cloudflare Terms of Service](https://www.cloudflare.com/terms/) and [Privacy Policy](https://www.cloudflare.com/privacypolicy/).

## Contributors

- [Wilson Tovar](https://github.com/krthr) - creator and maintainer
