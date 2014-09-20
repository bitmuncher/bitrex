bitrex
======

Deployment tasks for Rex (rexify.org)

This tasks install different server software directly
from project pages. Do not forget to modify Rexfile 
for your needs!

You must run the task bitrex:prepare_debian before you
can install the servers.

The following tasks are currently available:
<pre>
 bitrex:cleanup_debian     Cleanup the system from unneeded stuff like compilers etc. (Debian)
 bitrex:config_apache      Configure Apache webserver
 bitrex:install_apache     Install Apache webserver
 bitrex:install_php        Install PHP
 bitrex:prepare_debian     Prepare the system to use BitRex deployment tasks (Debian)
 bitrex:uninstall_apache   Uninstall Apache webserver
</pre>
