require_relative 'spec_helper'

describe 'ts3_configure' do
  # Stub out methods here first, so that any tests later on don't have issues.
  before do
    # Assume that systemd doesnt have an issue reloading its own cache
    stub_command('systemctl daemon-reload').and_return(0)
  end

  describe 'job control options' do
    describe 'manual' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_configure']) do |node|
          node.set['ts3_install']                   = {}
          node.set['ts3_configure']['user']         = 'teamspeakd'
          node.set['ts3_configure']['install_dir']  = '/srv/ts3/'
          node.set['ts3_configure']['server_name']  = 'testing'
          node.set['ts3_configure']['job_control']  = 'manual'
        end.converge('recipe[ts3::_test_configure]')
      end

      it { expect(chef_run).to create_user('teamspeakd').with(system: true) }
      it { expect(chef_run).to_not create_template('/etc/systemd/system/ts3-testing.service') }
      it { expect(chef_run).to_not run_execute('systemctl daemon-reload') }
    end

    describe 'systemd' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_configure']) do |node|
          node.set['ts3_install']                   = {}
          node.set['ts3_configure']['user']         = 'teamspeakd'
          node.set['ts3_configure']['install_dir']  = '/srv/ts3/'
          node.set['ts3_configure']['server_name']  = 'testing'
          node.set['ts3_configure']['job_control']  = 'systemd'
        end.converge('recipe[ts3::_test_configure]')
      end

      it { expect(chef_run).to create_user('teamspeakd').with(system: true) }
      it { expect(chef_run).to create_template('/etc/systemd/system/ts3-testing.service') }
      it { expect(chef_run).to run_execute('systemctl daemon-reload') }
    end
  end
end

