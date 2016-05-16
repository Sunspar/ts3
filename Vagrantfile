# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Set the version of chef to install using the vagrant-omnibus plugin
  # NOTE: You will need to install the vagrant-omnibus plugin:
  #
  #   $ vagrant plugin install vagrant-omnibus
  #
  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.chef_version = 'latest'
  end

  # Define each vm you want to test against.
  config.vm.define 'ubuntu-1510', autostart: false do |ubuntu|
    ubuntu.vm.hostname  = 'ubuntu-1510'
    ubuntu.vm.box       = 'ubuntu/wily64'
  end

  config.vm.define 'fedora-23', autostart: false do |fedora|
    fedora.vm.hostname  = 'fedora-23'
    fedora.vm.box       = 'bento/fedora-23'
  end

  # Configure the VM's networking.
  config.vm.network :private_network, type: 'dhcp'

  # Share folders to the VM.
  # config.vm.synced_folder "/path/to/host/directory" "/path/to/vm/directory"

  # Define the providers.
  config.vm.provider :virtualbox do |vb|
    vb.gui    = false
  end

  # Are we using Berkshelf? (hint: probably)
  config.berkshelf.enabled = true

  # Configure the provisioning process.
  config.vm.provision :chef_solo do |chef|
    chef.json = {
    }

    chef.run_list = [
        'recipe[ts3::default]'
    ]
  end
end
