actions :run
default_action :run

attribute :user, kind_of: String, required: true
attribute :install_dir, kind_of: String, required: true
attribute :server_name, kind_of: String, default: 'server'
attribute :job_control, kind_of: String, default: 'manual'
attribute :ini_parameters, kind_of: Hash, default: {}
