require "crest"

module Untun::Cloudflared
  extend self

  LINUX_URLS = {
    aarch64: "cloudflared-linux-arm64",
    arm:     "cloudflared-linux-arm",
    bits64:  "cloudflared-linux-amd64",
    i386:    "cloudflared-linux-386",
  }

  MACOS_URLS = {
    aarch64: "cloudflared-darwin-amd64.tgz",
    bits64:  "cloudflared-darwin-amd64.tgz",
  }

  WINDOWS_URLS = {
    bits64: "cloudflared-windows-amd64.exe",
    i386:   "cloudflared-windows-386.exe",
  }

  def already_installed? : Bool
    File.exists?(CLOUDFLARED_BIN_PATH) && File::Info.executable?(CLOUDFLARED_BIN_PATH)
  end

  def install_cloudflared(to : Path = CLOUDFLARED_BIN_PATH, version : String = CLOUDFLARED_VERSION) : Path
    {% if flag?(:linux) %}
      install_linux(to, version)
    {% elsif flag?(:darwin) %}
      install_macos(to, version)
    {% elsif flag?(:windows) %}
      install_windows(to, version)
    {% else %}
      raise NotImplementedError.new("Unsupported platform: #{Crystal::DESCRIPTION}")
    {% end %}
  end

  private def install_linux(to : Path, version : String) : Path
    arch = get_arch
    file = LINUX_URLS[arch]?

    raise NotImplementedError.new("Unsupported architecture: #{arch}") unless file

    download_path = Path[to.to_s]
    download(resolve_base(version) + file, download_path)

    File.chmod(download_path, 0o755)
    download_path
  end

  private def install_macos(to : Path, version : String) : Path
    arch = get_arch
    file = MACOS_URLS[arch]?

    raise NotImplementedError.new("Unsupported architecture: #{arch}") unless file

    tar_file = Path["#{to}.tgz"]
    download(resolve_base(version) + file, tar_file)

    command = "tar -xzf #{tar_file}"
    Log.debug { "Extracting to #{to} using: #{command}" }

    result = Process.run(command, shell: true, chdir: to.dirname)
    raise "Failed to extract cloudflared: #{command}" unless result.success?

    File.delete(tar_file)
    File.rename(Path[to.dirname, "cloudflared"], to)
    File.chmod(to, 0o755)

    to
  end

  private def install_windows(to : Path, version : String) : Path
    arch = get_arch
    file = WINDOWS_URLS[arch]?

    raise NotImplementedError.new("Unsupported architecture: #{arch}") unless file

    download_path = Path[to.to_s]
    download(resolve_base(version) + file, download_path)
    download_path
  end

  private def resolve_base(version : String) : String
    version == "latest" ? "#{RELEASE_BASE}latest/download/" : "#{RELEASE_BASE}download/#{version}/"
  end

  private def download(url : String, to : Path) : Path
    Log.debug { "Downloading #{url} to #{to}" }

    dirname = File.dirname(to)
    unless Dir.exists?(dirname)
      Log.debug { "Creating #{dirname}" }
      Dir.mkdir_p(dirname)
    end

    Crest.get(url) do |response|
      File.open(to, "wb") do |file|
        IO.copy(response.body_io, file)
      end
    end

    to
  end

  private def get_arch : Symbol
    {% if flag?(:aarch64) %}
      :aarch64
    {% elsif flag?(:bits64) %}
      :bits64
    {% elsif flag?(:arm) %}
      :arm
    {% elsif flag?(:i386) %}
      :i386
    {% else %}
      raise NotImplementedError.new("Unsupported architecture")
    {% end %}
  end
end
