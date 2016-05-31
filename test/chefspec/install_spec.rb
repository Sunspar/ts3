require_relative 'spec_helper'

describe 'ts3_install' do
  install_dir = '/srv/ts3/'
  action      = 'install'

  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
      node.set['ts3_install'] = {}
      node.set['ts3_install']['version']     = '3.0.12.4'
      node.set['ts3_install']['install_dir'] = install_dir
      node.set['ts3_install']['action']      = action
    end.converge('recipe[ts3::_test_install]')
  end

  it 'creates the install dir' do
    expect(chef_run).to create_directory('/srv/ts3/')
  end

  describe ' version < 3.0.12' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
        node.set['ts3_install'] = {}
        node.set['ts3_install']['version']     = '3.0.8'
        node.set['ts3_install']['install_dir'] = install_dir
        node.set['ts3_install']['action']      = action
      end.converge('recipe[ts3::_test_install]')
    end

    it 'downloads the server executable' do
      expect(chef_run).to create_remote_file('download server code').with(path: File.join(Chef::Config['file_cache_path'], 'teamspeak3-server_linux-amd64-3.0.8.tar.gz'))
    end
  end

  describe 'version >= 3.0.12' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
        node.set['ts3_install'] = {}
        node.set['ts3_install']['version']     = '3.0.12.4'
        node.set['ts3_install']['install_dir'] = install_dir
        node.set['ts3_install']['action']      = action
      end.converge('recipe[ts3::_test_install]')
    end

    it 'downloads the server executable' do
      expect(chef_run).to create_remote_file('download server code').with(path: File.join(Chef::Config['file_cache_path'], 'teamspeak3-server_linux_amd64-3.0.12.4.tar.bz2'))
    end
  end
end

describe 'ts3_install delete' do
  install_dir = '/srv/ts3/'
  action      = 'delete'

  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
      node.set['ts3_install'] = {}
      node.set['ts3_install']['version']     = '3.0.12.4'
      node.set['ts3_install']['install_dir'] = install_dir
      node.set['ts3_install']['action']      = action
    end.converge('recipe[ts3::_test_install]')
  end

  it 'deletes valid install dir' do
    allow(::File).to receive(:exist?).and_call_original
    allow(::File).to receive(:exist?).with('/srv/ts3/ts3server_startscript.sh').and_return(true)
    expect(chef_run).to delete_directory('remove install dir').with(path: '/srv/ts3/')
  end

  it 'does not delete invalid install dir' do
    allow(::File).to receive(:exist?).and_call_original
    allow(::File).to receive(:exist?).with('/srv/ts3/ts3server_startscript.sh').and_return(false)
    expect(chef_run).to_not delete_directory('remove install dir').with(path: '/srv/tss3/')
  end
end
