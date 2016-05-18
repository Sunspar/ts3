require_relative 'spec_helper'

describe 'ts3_install' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_install']) do |node|
      node.set['ts3_install'] = {}
      node.set['ts3_install']['version']     = '3.0.8'
      node.set['ts3_install']['install_dir'] = '/srv/ts3/'
      node.set['ts3_install']['action']      = 'install'
    end.converge('recipe[ts3::_test_install]')
  end

  it { expect(chef_run).to create_directory('/srv/ts3/') }
end
