use_inline_resources

action :install do
  if resource_exists?
    new_resource.updated_by_last_action(false)
  else
    directory 'create install dir' do
      path new_resource.install_dir
    end

    # TODO: Is this valid for all versions?
    url = "http://teamspeak.gameserver.gamed.de/ts3/releases/#{new_resource.version}/teamspeak3-server_linux_amd64-#{new_resource.version}.tar.bz2"
    remote_file 'download server code' do
      source url
      path  ::File.join Chef::Config[:file_cache_path], "teamspeak3-server_linux_amd64-#{new_resource.version}.tar.bz2"
    end

    # TODO: if bz2 archive
    execute 'extract bz2 archive' do
      cwd     Chef::Config[:file_cache_path]
      command "bzip2 -d teamspeak3-server_linux_amd64-#{new_resource.version}.tar.bz2"
    end

    # TODO: if tar archive
    execute 'untar archive to install dir' do
      cwd Chef::Config['file_cache_path']
      command "tar -xf teamspeak3-server_linux_amd64-#{new_resource.version}.tar -C #{new_resource.install_dir} --strip-components=1"
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
  ::File.exists?(::File.join path, 'ts3server')
end

def load_current_resource
  @current_resource = Chef::Resource::Ts3Install.new(version: new_resource.version, install_dir: new_resource.install_dir)
  @current_resource
end