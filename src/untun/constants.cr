module Untun
  CLOUDFLARED_VERSION = ENV.fetch("CLOUDFLARED_VERSION", "2025.9.0")
  RELEASE_BASE        = "https://github.com/cloudflare/cloudflared/releases/"

  CLOUDFLARED_BIN_PATH = Path[
    Dir.tempdir,
    "untun-cr",
    {% if flag?(:windows) %}
      "cloudflared.#{CLOUDFLARED_VERSION}.exe"
    {% else %}
      "cloudflared"
    {% end %},
  ]

  CLOUDFLARED_NOTICE = "
  🔥 Your installation of cloudflared software constitutes a symbol of your signature
   indicating that you accept the terms of the Cloudflare License, Terms and Privacy Policy.

  ❯ License:         `https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/license/`
  ❯ Terms:           `https://www.cloudflare.com/terms/`
  ❯ Privacy Policy:  `https://www.cloudflare.com/privacypolicy/`
  "
end
