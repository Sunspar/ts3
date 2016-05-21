require_relative 'spec_helper'

describe 'ts3_configure' do
  user        = 'teamspeakd'
  install_dir = '/srv/ts3/'
  server_name = 'testing'

  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_configure']) do |node|
      node.set['ts3_install']                   = {}
      node.set['ts3_configure']['user']         = user
      node.set['ts3_configure']['install_dir']  = install_dir
      node.set['ts3_configure']['server_name']  = server_name
      node.set['ts3_configure']['job_control']  = 'manual'
    end.converge('recipe[ts3::_test_configure]')
  end

  it 'creates the service account' do
    expect(chef_run).to create_user('teamspeakd').with(system: true)
  end

  it 'runs chown -R on the install dir' do
    stub_command('chown -R teamspeakd:teamspeakd /srv/ts3/').and_return(0)
    expect(chef_run).to run_execute('server directory ownership').with(cwd: '/srv/ts3/', command: 'chown -R teamspeakd:teamspeakd /srv/ts3/')
  end

  describe 'job control options' do
    describe 'manual' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.10', step_into: ['ts3_configure']) do |node|
          node.set['ts3_install']                   = {}
          node.set['ts3_configure']['user']         = user
          node.set['ts3_configure']['install_dir']  = install_dir
          node.set['ts3_configure']['server_name']  = server_name
          node.set['ts3_configure']['job_control']  = 'manual'
        end.converge('recipe[ts3::_test_configure]')
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
          node.set['ts3_configure']['user']         = user
          node.set['ts3_configure']['install_dir']  = install_dir
          node.set['ts3_configure']['server_name']  = server_name
          node.set['ts3_configure']['job_control']  = 'systemd'
        end.converge('recipe[ts3::_test_configure]')
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

