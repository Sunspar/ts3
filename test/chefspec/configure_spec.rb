require_relative 'spec_helper'

describe 'ts3_configure' do
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

      it 'creates the service account' do
        expect(chef_run).to create_user('teamspeakd').with(system: true)
      end

      it 'does not create a job control service script' do
        expect(chef_run).to_not create_template('/etc/systemd/system/ts3-testing.service')
      end

      it 'does not call any of the job control reload commands' do
        expect(chef_run).to_not run_execute('systemctl daemon-reload')
      end
    end

    describe 'systemd' do
      before do
        stub_command('systemctl daemon-reload').and_return(0)
      end

      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_configure']) do |node|
          node.set['ts3_install']                   = {}
          node.set['ts3_configure']['user']         = 'teamspeakd'
          node.set['ts3_configure']['install_dir']  = '/srv/ts3/'
          node.set['ts3_configure']['server_name']  = 'testing'
          node.set['ts3_configure']['job_control']  = 'systemd'
        end.converge('recipe[ts3::_test_configure]')
      end

      it 'creates the service account' do
        expect(chef_run).to create_user('teamspeakd').with(system: true)
      end

      it 'creates the systemd service file' do
        expect(chef_run).to create_template('/etc/systemd/system/ts3-testing.service')
      end

      it 'calls the systemd reload command' do
        expect(chef_run).to run_execute('systemctl daemon-reload')
      end
    end
  end
end

