ts3_configure 'demo Teamspeak 3 server configuration' do
  user        node['ts3_configure']['user']
  install_dir node['ts3_configure']['install_dir']
  server_name node['ts3_configure']['server_name']
  job_control node['ts3_configure']['job_control']
end

service 'start server' do
  not_if       { node['ts3_configure']['job_control'] == 'manual' }
  service_name  "ts3-#{node['ts3_configure']['server_name']}"
  action        :restart
end
