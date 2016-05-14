use_inline_resources

action :run do
  user 'system account' do
    username  new_resource.user
    system    true
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
      files =[{
        source:     'job_control/systemd/ts3-server.service.erb',
        path:       "/etc/systemd/system/ts3-#{new_resource.server_name}.service",
        variables:  resource_job_params
      }]
      service_reset_command = 'systemctl daemon-reload'
    when 'manual'
      files = []
      service_reset_command = nil
    else
      raise Chef::Exceptions::UnsupportedAction, 'The ts3_configure LWRP does not currently support this management system.'
  end

  files.each do |file|
    template "job control - #{file[:source]}" do
      source    file[:source]
      path      file[:path]
      variables file[:variables]
      action    action
    end
  end

  execute 'fix job cache' do
    only_if service_reset_command
    command service_reset_command
  end
end

def resource_job_params
  {
    user:         new_resource.user,
    install_dir:  new_resource.install_dir
  }
end