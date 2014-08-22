### Bitmuncher's Deployment Tasks for Debian-based servers ###


###
# do the configuration here

###
# before using this deployment tasks, create a non-root user on the target system
# and the folder /operation. This folder must be owned by the non-root-user. Your 
# non-root-user should be able to run iptables and apt-get via sudo.
#
# all software is installed in '(get "base_dir)."/<component-name>"',
# by default '(get "base_dir)' is set to /operation
# for example: Apache webserver is installed in (get "base_dir)."/apache/"

###
# set the values in this file according to your needs

use Rex;

# versions you like to use
set apache_version => "2.4.10";
set php_version => "5.5.15"; # only tested with PHP 5.5.x!
set tomcat_version => "8.0.9"; # only tested with Tomcat 8!

# set your username and group for the user to use to run and deploy the software
set user => "operation";
set user_group => 'operation';

# Email address for tech contacts
set admin_email => 'your@email.net';

# SSH keys for authentication
private_key $ENV{'HOME'}.'/.ssh/id_dsa';
public_key $ENV{'HOME'}.'/.ssh/id_dsa.pub';
# if you like to use password authentication for SSH, uncomment the following lines
# and remove the lines for key files
#set password => "<password>";
#set -passauth;

# put your servers in this group
set group => "servers" => "yourserver.net";

# set domain for webserver etc. (for virtual hosts see below)
set domain => "yourserver.net";

# base directory for installations
set base_dir => '/operation';

# apache configuration
set apache_port => '8181';
set apache_user => 'operation';
set apache_group => 'operation';
# map domains and docroots
my %vhosts = (
	      'yourdomain1.com' => '/operation/www/yourdomain1.com',
	      'yourdomain2.com' => '/operation/www/yourdomain2.com',
	     );
set apache_vhosts => \%vhosts;

# tomcat configuration
set tomcat_port => '8081';

require bitrex;
