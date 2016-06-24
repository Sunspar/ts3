resource_name :ts3_server_install
default_action :install

property :install_dir, String, required: true
property :version, String, required: true

# Install the TS3 server.
action :install do
  if resource_exists? && resource_version == version
    updated_by_last_action(false)
  else
    directory 'create install dir' do
      path install_dir
    end

    # Version 3.0.12 (and later?) are supplied as *.tar.bz2 archives, instead of the usual *.tar.gz.
    v = version.split('.').map(&:to_i)
    extension = 'tar.gz'  if v[0] == 3 && v[1] == 0 && v[2] <  12
    extension = 'tar.bz2' if v[0] == 3 && v[1] == 0 && v[2] >= 12

    # Version 3.0.12 (and later?) separate the OS and arch with an underscore, rather than a dash
    os_arch_separator = '-' if v[0] == 3 && v[1] == 0 && v[2] <= 11
    os_arch_separator = '_' if v[0] == 3 && v[1] == 0 && v[2] >= 12

    # Set architecture (32 vs 64 bit)
    case node['kernel']['machine']
    when 'x86_64', 'amd64'
      arch = 'amd64'
    when 'i386', 'i686'
      arch = 'x86'
    else
      # rubocop:disable Metrics/LineLength
      raise Chef::Exceptions::UnsupportedAction, "ts3_server_install does not understand or support your platform architecture: #{node['kernel']['machine']}"
      # rubocop:enable Metrics/LineLength
    end

    remote_file 'download server code' do
      # rubocop:disable Metrics/LineLength
      source  "http://dl.4players.de/ts/releases/#{version}/teamspeak3-server_linux#{os_arch_separator}#{arch}-#{version}.#{extension}"
      path    ::File.join(Chef::Config[:file_cache_path], "teamspeak3-server_linux#{os_arch_separator}#{arch}-#{version}.#{extension}")
      # rubycop:enable Metrics/LineLength
    end

    # BZ2 extracts to the tar, which we need to then extract to the install dir.
    bash 'extract bz2 archive' do
      only_if { extension == 'tar.bz2' }
      cwd     Chef::Config['file_cache_path']
      code <<-EOH
        bzip2 -d teamspeak3-server_linux#{os_arch_separator}#{arch}-#{version}.tar.bz2
        tar -xf teamspeak3-server_linux#{os_arch_separator}#{arch}-#{version}.tar -C #{install_dir} --strip-components=1
      EOH
    end

    # For gzip archives, we can extract it directly to the install dir
    execute 'extract gzip archive' do
      only_if { extension == 'tar.gz' }
      cwd     Chef::Config['file_cache_path']
      command "tar -xzf teamspeak3-server_linux#{os_arch_separator}#{arch}-#{version}.tar.gz -C #{install_dir} --strip-components=1"
    end

    # Write a hint file for future runs
    file 'ts3 version hint' do
      content version
      path ::File.join(install_dir, '.ts3-version')
    end

    updated_by_last_action(true)
  end
end

# Removes TS3 Server from the resource's install_dir.
action :delete do
  if resource_exists?
    directory 'remove install dir' do
      path    install_dir
      action  :delete
    end

    updated_by_last_action(true)
  else
    updated_by_last_action(false)
  end
end

# Grab the version of TS3 installed by the ts3_server_install resource.
#
# @return [String] the version found in the .ts3-version file at the resource's install_dir, or the string '0'
#   if the file is missing.
def resource_version
  version_file = ::File.join(install_dir, '.ts3-version')
  if ::File.exist?(version_file)
    result = ::File.read(version_file)
  else
    result = '0'
  end
  result
end

# Determine whether the resource represents an existing installation.
#
# @return [TrueClass, FalseClass] whether or not TS3 is installed at the resource's install_dir
def resource_exists?
  path_exists? install_dir
end

# Determine whether the given path is a reference to an installation of the TeamSpeak 3 server.
#
# @return [TrueClass, FalseClass] whether or not TS3 is installed at the given path.
def path_exists?(path)
  ::File.exist?(::File.join(path, 'ts3server_startscript.sh'))
end

def load_current_resource
  @current_resource = Chef::Resource::Ts3ServerInstall.new(
    version: version,
    install_dir: install_dir
  )
  @current_resource
end
