ts3_install 'demo installation of TeamSpeak 3' do
  version     '3.0.8'
  install_dir '/srv/ts3'
end

ts3_configure 'demo Teamspeak 3 server configuration' do
  user        'teamspeakd'
  install_dir '/srv/ts3'
  server_name 'server'
  job_control 'systemd'
end