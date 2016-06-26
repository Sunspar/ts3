# ts3 Cookbook

vNext

- Switched to 12.5-style for resource definition for the `ts3_install` and `ts3_configure` resources
- Added testing and support for systemd compatible versions of Debian and CentOS
- Added SysV init support in `ts3_server_configure`

v 0.2.0 (16 June 2016)

- Fixed an issue where template files weren't being pulled in properly during the convergence process.

v 0.1.3 (30 May 2016)

- Added very basic inspec tests (does the server start up? port is ok?)
- Cleaned up chefspec tests
- fixed downloaded file extension so that both sides of the 3.0.12 divide worked as expected (bz2 versus tar.gz)
- added Rakefile tasks to make testing and deployment easier

v0.1.1 (18 May 2016)

- RuboCop cleanup (minus a few lines which are > 120 characters)
- Initial Kitchen setup for ubuntu and fedora systems
- pulled the service startup out of the LWRP (let caller decide when to start services)

v0.1.0 (15 May 2016)

- Inital release with a very basic install and configure LWRP, along with demo recipe showing the process.
