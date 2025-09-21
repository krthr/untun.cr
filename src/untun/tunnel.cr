module Untun
  extend self

  def start_tunnel(
    url : String? = nil,
    port : Int32 | String = 3000,
    hostname : String = "localhost",
    protocol : String = "http",
    verify_tls : Bool = false,
    accept_cloudflare_notice : Bool = false,
  ) : Cloudflared::TunnelResult?
    url ||= "#{protocol}://#{hostname}:#{port}"

    Log.info { "Starting cloudflared tunnel to #{url}" }

    unless Cloudflared.already_installed?
      Log.info { CLOUDFLARED_NOTICE }

      can_install = accept_cloudflare_notice || ENV.has_key?("UNTUN_ACCEPT_CLOUDFLARE_NOTICE")

      unless can_install
        Log.fatal { "Skipping tunnel setup." }
        return nil
      end

      Cloudflared.install_cloudflared
    else
      Log.debug { "cloudflared already installed in #{CLOUDFLARED_BIN_PATH}" }
    end

    options = Cloudflared::TunnelStartOptions.new
    options["--url"] = url

    unless verify_tls
      options["--no-tls-verify"] = ""
    end

    Cloudflared.start_cloudflared_tunnel(options)
  end
end
