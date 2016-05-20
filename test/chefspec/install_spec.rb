require_relative 'spec_helper'

describe 'ts3_install install, < 3.0.12' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
      node.set['ts3_install'] = {}
      node.set['ts3_install']['version']     = '3.0.8'
      node.set['ts3_install']['install_dir'] = '/srv/ts3/'
      node.set['ts3_install']['action']      = 'install'
    end.converge('recipe[ts3::_test_install]')
  end

  it 'creates the install dir' do
    expect(chef_run).to create_directory('/srv/ts3/')
  end

  it 'downloads the server executable' do
    expect(chef_run).to create_remote_file('download server code').with(path: File.join(Chef::Config['file_cache_path'], 'teamspeak3-server_linux-amd64-3.0.8.tar.gz'))
  end
end

describe 'ts3_install install, >= 3.0.12' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
      node.set['ts3_install'] = {}
      node.set['ts3_install']['version']     = '3.0.12.4'
      node.set['ts3_install']['install_dir'] = '/srv/ts3/'
      node.set['ts3_install']['action']      = 'install'
    end.converge('recipe[ts3::_test_install]')
  end

  it 'creates the install dir' do
    expect(chef_run).to create_directory('/srv/ts3/')
  end

  it 'downloads the server executable' do
    expect(chef_run).to create_remote_file('download server code').with(path: File.join(Chef::Config['file_cache_path'], 'teamspeak3-server_linux_amd64-3.0.12.4.tar.bz2'))
  end
end

describe 'ts3_install delete' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
      node.set['ts3_install'] = {}
      node.set['ts3_install']['version']     = '3.0.8'
      node.set['ts3_install']['install_dir'] = '/srv/ts3/'
      node.set['ts3_install']['action']      = 'delete'
    end.converge('recipe[ts3::_test_install]')
  end

  it 'deletes when called with a valid start script in the install dir' do
    allow(::File).to receive(:exist?).and_call_original
    allow(::File).to receive(:exist?).with('/srv/ts3/ts3server_startscript.sh').and_return(true)
    expect(chef_run).to delete_directory('remove install dir').with(path: '/srv/ts3/')
  end

  it 'does not delete when called without the start script in the install dir' do
    allow(::File).to receive(:exist?).and_call_original
    allow(::File).to receive(:exist?).with('/srv/ts3/ts3server_startscript.sh').and_return(false)
    expect(chef_run).to_not delete_directory('remove install dir').with(path: '/srv/ts3/')
  end
end
