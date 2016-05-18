actions :install, :delete
default_action :install

attribute :install_dir, kind_of: String, required: true
attribute :version, kind_of: String, required: true
