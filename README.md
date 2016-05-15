# TS3
LWRPs for installing and configuring TeamSpeak 3 servers.

## Usage
Simply call the `ts3_install` LWRP to handle installing instances and the `ts3_configure` LWRP for configuring pre-existing instances.

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
Currently, only 'manual' and 'systemd' types are supported. Manual simply indicates that no particular system is to be used, and that the administrator will handle starting/stopping the server themselves. More systems are planned, notably upstart and supervisor.