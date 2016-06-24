ts3_server_configure 'demo Teamspeak 3 server configuration' do
  service_user  node['ts3_server_configure']['user']
  install_dir   node['ts3_server_configure']['install_dir']
  server_name   node['ts3_server_configure']['server_name']
  job_control   node['ts3_server_configure']['job_control']
end

service 'start server' do
  not_if       { node['ts3_server_configure']['job_control'] == 'manual' }
  service_name  "ts3-#{node['ts3_server_configure']['server_name']}"
  action        :restart
end
