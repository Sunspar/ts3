# TS3
LWRPs for installing and configuring TeamSpeak 3 servers.

## Supported Setups
In general, an OS is said to be supported if it is listed in `.kitchen.yml` under the platforms section.  
Although all supported OS and job control systems _should_ work, we test using the default systems provided by the OS (for example, systemd on Fedora 23).  

## Usage
Simply call the `ts3_install` LWRP to handle installing instances and the `ts3_configure` LWRP for configuring pre-existing instances.

## Running Tests
Unit tests can be found under the `test/chefspec` directory and can be run via `bundle exec rspec test/chefspec`.  
Integration tests are written with InSpec and can be found under the `test/inspec` directory.  
Run rubocop from the cookbook root: `bundle exec rubocop .`.  
Run foodcritic from the cookbook root for chef-specific lint checking: `bundle exec foodcritic .`.  

## Resource Providers
### ts3_install
Installs the TeamSpeak 3 server.

| Attribute | Required? | Type | Default | Usage |
| :-: | :-: | :-: | :-: | :-: |
| install_dir | true | String | --- | The location on the filesystem to install the TS3 server to. |
| version | true | String | --- | The version of the server software to install. |

### ts3_configure
Configures a TeamSpeak 3 server.

| Attribute | Required? | Type | Default | Usage |
| :-: | :-: | :-: | :-: | :-: |
| user | true | String | teamspeakd | The username of the system account which manages the server. |
| install_dir | true | String | --- | The location of the server on the filesystem. |
| server_name | false | String | server | The alias for this server. Used to differentiate job control scripts from one another. |
| job_control | false | String | manual | The service system used by your hardware. Used to create management scripts automatically. |

#### Job Control types
The following job control systems are supported by the LWRP:

| Type | Description
| :-: | :-:
| manual | Don't bother installing any scripts, as the server will be managed manually by the administrator.
| systemd | Install a service for systemd managed by systemctl.
