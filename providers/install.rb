use_inline_resources

def whyrun_supported?
  true
end

action :install do
  if resource_exists?
    new_resource.updated_by_last_action(false)
  else
    directory 'create install dir' do
      path new_resource.install_dir
    end

    # Version 3.0.12 (and later?) are supplied as *.tar.bz2 archives, instead of the usual *.tar.gz.
    version = resource_split_version
    extension = 'tar.gz'  if version[0] == 3 && version[1] == 0 && version[2] <  12
    extension = 'tar.bz2' if version[0] == 3 && version[1] == 0 && version[2] >= 12

    # Version 3.0.12 (and later?) separate the OS and arch with an underscore, rather than a dash
    os_arch_separator = '-' if version[0] == 3 && version[1] == 0 && version[2] <= 11
    os_arch_separator = '_' if version[0] == 3 && version[1] == 0 && version[2] >= 12

    # Set architecture (32 vs 64 bit)
    case node['kernel']['machine']
    when 'x86_64', 'amd64'
      arch = 'amd64'
    when 'i386', 'i686'
      arch = 'x86'
    else
      raise Chef::Exceptions::UnsupportedAction, "ts3_install does not understand or support your platform architecture: #{node['kernel']['machine']}"
    end

    remote_file 'download server code' do
      source  "http://dl.4players.de/ts/releases/#{new_resource.version}/teamspeak3-server_linux#{os_arch_separator}#{arch}-#{new_resource.version}.#{extension}"
      path    ::File.join(Chef::Config[:file_cache_path], "teamspeak3-server_linux#{os_arch_separator}#{arch}-#{new_resource.version}.#{extension}")
    end

    # BZ2 extracts to the tar, which we need to then extract to the install dir.
    bash 'extract bz2 archive' do
      only_if { extension == 'tar.bz2' }
      cwd     Chef::Config['file_cache_path']
      code <<-EOH
        bzip2 -d teamspeak3-server_linux#{os_arch_separator}#{arch}-#{new_resource.version}.tar.bz2
        tar -xf teamspeak3-server_linux#{os_arch_separator}#{arch}-#{new_resource.version}.tar -C #{new_resource.install_dir} --strip-components=1
      EOH
    end

    # For gzip archives, we can extract it directly to the install dir
    execute 'extract gzip archive' do
      only_if { extension == 'tar.gz' }
      cwd     Chef::Config['file_cache_path']
      command "tar -xzf teamspeak3-server_linux#{os_arch_separator}#{arch}-#{new_resource.version}.tar.gz -C #{new_resource.install_dir} --strip-components=1"
    end

    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if resource_exists?
    directory 'remove install dir' do
      path    new_resource.install_dir
      action  :delete
    end

    new_resource.updated_by_last_action(true)
  else
    new_resource.updated_by_last_action(false)
  end
end

def resource_exists?
  path_exists? new_resource.install_dir
end

def path_exists?(path)
  ::File.exist?(::File.join(path, 'ts3server_startscript.sh'))
end

# Coerces a version string into an integer array.
# Params: None (+new_resource+ implied)
# Returns: +Array[Fixnum]+:: The array representation of the version number, with major version in index 0.
def resource_split_version
  new_resource.version.split('.').map(&:to_i)
end

def load_current_resource
  @current_resource = Chef::Resource::Ts3Install.new(
    version: new_resource.version,
    install_dir: new_resource.install_dir)
  @current_resource
end
