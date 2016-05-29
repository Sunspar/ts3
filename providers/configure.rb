use_inline_resources

def whyrun_supported?
  true
end

action :run do
  user 'system account' do
    username  new_resource.user
    system    true
  end

  template 'ts3server ini config' do
    source    'ts3server.ini.erb'
    path      ::File.join(new_resource.install_dir, 'ts3server.ini')
    variables ( default_ini_params.merge(new_resource.ini_parameters) )
  end

  # This is hacky, but hear me out....
  # In order for the server to operate correctly, the entire install location needs to be owned by the
  # daemon account. Due to a long standing issue with the directory resource (of which there are two camps,
  # both of which make valid arguments), the directory resource does not go into folders and files below it
  # when setting ownership, even though there is a 'recursive' field.
  #
  # As a result, we need this hacky shelling out to forcibly test each file rooted at +instal_dir+, so that
  # any changes made outside of chef don't permanently bork things. That is, running +ts3_configure :run+
  # /should/ in all cases return you to a functional server if you poke around and mess things up
  # (within reason :) )
  #
  # TODO: Find a better way to treat ownership convergence here
  #
  # See: https://tickets.opscode.com/browse/CHEF-1621
  execute 'server directory ownership' do
    cwd new_resource.install_dir
    command "chown -R #{new_resource.user}:#{new_resource.user} #{new_resource.install_dir}"
  end

  case new_resource.job_control
  when 'systemd'
    files = [{
      source:     'job_control/systemd/ts3-server.service.erb',
      path:       "/etc/systemd/system/ts3-#{new_resource.server_name}.service",
      variables:  resource_job_params
    }]
    service_reset_command = 'systemctl daemon-reload'
    service_enable_command = "systemctl enable ts3-#{new_resource.server_name}"
  when 'manual'
    files = []
    service_reset_command = nil
    service_enable_command = nil
  else
    raise Chef::Exceptions::UnsupportedAction, 'This management system is currently unsupported.'
  end

  files.each do |file|
    template "job control - #{file[:source]}" do
      source    file[:source]
      path      file[:path]
      variables file[:variables]
      action    action
    end
  end

  execute 'enable service' do
    only_if { service_enable_command }
    command service_enable_command
  end

  execute 'reload service cache' do
    only_if { service_reset_command }
    command service_reset_command
  end

  new_resource.updated_by_last_action(true)
end

def resource_job_params
  {
    user:         new_resource.user,
    install_dir:  new_resource.install_dir
  }
end

def default_ini_params
  {
    machine_id:                 '',
    default_voice_port:         '9987',
    voice_ip:                   '0.0.0.0',
    licensepath:                '',
    filetransfer_port:          '30033',
    filetransfer_ip:            '0.0.0.0',
    query_port:                 '10011',
    query_ip:                   '0.0.0.0',
    query_ip_whitelist:         'query_ip_whitelist.txt',
    query_ip_blacklist:         'query_ip_blacklist.txt',
    query_skipbruteforcecheck:  '0',
    dbplugin:                   'ts3db_sqlite3',
    dbpluginparameter:          '',
    dbsqlpath:                  'sql/',
    dbsqlcreatepath:            'create_sqlite/',
    dbconnections:              '10',
    dblogkeepdays:              '90',
    dbclientkeepdays:           '30',
    logpath:                    'logs/',
    logquerycommands:           '0',
    logappend:                  '0'
  }
end
