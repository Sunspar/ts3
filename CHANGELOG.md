# ts3 Cookbook

v 0.1.3

- Added very basic inspec tests (does the server start up? port is ok?)
- Cleaned up chefspec tests
- fixed downloaded file extension so that both sides of the 3.0.12 divide worked as expected (bz2 versus tar.gz)
- added Rakefile tasks to make testing and deployment easier

v0.1.1

- RuboCop cleanup (minus a few lines which are > 120 characters)
- Initial Kitchen setup for ubuntu and fedora systems
- pulled the service startup out of the LWRP (let caller decide when to start services)

v0.1.0

- Inital release with a very basic install and configure LWRP, along with demo recipe showing the process.
