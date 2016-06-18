ts3_server_install 'demo installation of TeamSpeak 3' do
  version     node['ts3_install']['version']
  install_dir node['ts3_install']['install_dir']
  action      node['ts3_install']['action']
end
