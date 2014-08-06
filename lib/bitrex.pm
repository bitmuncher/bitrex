package bitrex;

use Rex -base;

###
# prepare the system for BitRex deployment
desc "Prepare the system to use BitRex deployment tasks (Debian)";
task "prepare_debian", group => "servers", sub {
	say "Installing needed packages...";
	# install some needed packages
	run "sudo apt-get -y install gnupg build-essential libapr1-dev libaprutil1-dev wget libxml2-dev openssl libssl-dev libsslcommon2-dev libcurl4-openssl-dev libbz2-dev libjpeg62-dev libpng12-dev libxpm-dev libfreetype6-dev libgmp-dev libreadline6-dev librecode-dev libxslt1-dev";

	say "Importing needed GPG keys...";
	# import GPG keys for Apache webserver sources
	run "wget http://www.apache.org/dist/httpd/KEYS && gpg --import KEYS";
	# import GPG keys for PHP sources
	run "gpg --recv-keys --yes '90D90EC1'";
	run "gpg --recv-keys --yes '7267B52D'";

};

###
# remove unwanted stuff fromm the system
desc "Cleanup the system from unneeded stuff like compilers etc. (Debian)";
task "cleanup_debian", group => "servers", sub {
	run "sudo apt-get -y --purge remove gcc make wget libxml2-dev libaprutil1-dev libapr1-dev bison libssl-dev libbz2-dev libcurl4-openssl-dev libsslcommon2-dev libjpeg62-dev libpng12-dev libxpm-dev libfreetype6-dev libgmp-dev libreadline6-dev librecode-dev libxslt1-dev";
};

###
# install PHP for Apache webserver from source
desc "Install PHP";
task "install_php", group => "servers", sub {
	# create directory, download source and signature file
	say "Creating source directory if needed...";
	my $src_dir = (get "base_dir")."/src";	
	file $src_dir, ensure => "directory", owner => (get "user"), group => (get "user_group");

	say "Downloading source...";
#	my $url_tar = "http://de1.php.net/distributions/php-".(get "php_version").".tar.gz";
#	my $file_tar = ((get "base_dir")."/src/");
#	say $url_tar.' -> '.$file_tar;
#	download $url_tar, $file_tar;
#	my $url_asc = "http://de1.php.net/distributions/php-".(get "php_version").".tar.gz.asc";
#	my $file_asc = ((get "base_dir")."/src/");
#	say $url_asc.' -> '.$file_asc;
#	download $url_asc, $file_asc;
	run "cd ".$src_dir." && wget http://de1.php.net/distributions/php-".(get "php_version").".tar.gz";
	run "cd ".$src_dir." && wget http://de1.php.net/distributions/php-".(get "php_version").".tar.gz.asc";
	  

	say "Verifying downloaded packages...";
	my $out = run "cd ".$src_dir." && ".
	  "gpg --verify php-".(get "php_version").".tar.gz.asc php-".(get "php_version").".tar.gz";
	if (!($out =~ /Good signature from/)) {
		say "Couldn't verify source package for PHP.";
		print $out."\n";
		exit;
	} else {
		say "All seems to be fine. Continue...";
	}
	
	say "Extracting source...";
	run "cd ".$src_dir." && tar -xzf php-".(get "php_version").".tar.gz";

	say "Compiling source. This may take a wile. Please wait...";
	run "cd ".$src_dir."/php-".(get "php_version")." && ".
	  "./configure --enable-zip --enable-wddx --enable-sysvshm --enable-sysvsem --enable-sysvmsg --enable-soap --enable-shmop --with-recode --with-readline --with-mysql=/usr --enable-mbstring --with-gettext --with-png-dir --with-jpeg-dir --with-gd --with-pcre-dir --with-gmp --with-mhash --with-freetype-dir --with-xpm-dir --with-pcre-dir --enable-exif --enable-dba=shared --with-bz2 --enable-bcmath --enable-sigchild --with-apxs2=".(get "base_dir")."/apache/bin/apxs --prefix=".(get "base_dir")."/php --with-pear=".(get "base_dir")."/php/bin --with-config-file-path=".(get "base_dir")."/php/conf/ --with-libdir=lib64 --with-openssl --with-xsl=/usr --with-libxml-dir=/usr --with-pdo-mysql=/usr -with-curl=/usr";
	run "cd ".$src_dir."/php-".(get "php_version")." && make && make install";

	# apache configuration
	say "Adding configuration for apache...";
	my $php_apache_conf = (get "base_dir")."/apache/conf/extras.d/php.conf";
	file $php_apache_conf, source => "files/operation/apache/conf/extras.d/php.conf";
	
	# cleanup
	say "Removing source...";
	run "rm -r ".$src_dir."/*";

	say "Done.";
};

###
# install Apache webserver from source
desc "Install Apache webserver";
task "install_apache", group => 'servers', sub {
	say "Installing Apache webserver...";
	
	# create directory, download source and signature file
	say "Downloading source...";
	run "mkdir ".(get "base_dir")."/src";
	run "cd ".(get "base_dir")."/src && ".
	  "wget http://www.apache.org/dist/httpd/httpd-".(get "apache_version").".tar.gz";
	run "cd ".(get "base_dir")."/src && ".
	  "wget http://www.apache.org/dist/httpd/httpd-".(get "apache_version").".tar.gz.asc";

	# verify source with gpg
	say "Verifying source...";
	my $out = run "cd ".(get "base_dir")."/src && ".
	  "gpg --verify httpd-".(get "apache_version").".tar.gz.asc httpd-".(get "apache_version").".tar.gz";
	if(!($out =~ /Good signature from/)) {
		say "Couldn't verify source package for Apache.";
		print $out."\n";
		exit;
	} else {
		say "All seems to be fine. Continue...";
	}

	# compile and install
	say "Installing Apache from source. This can take a while...";
	run "cd ".(get "base_dir")."/src && tar -xzf httpd-".(get "apache_version").".tar.gz";
	run "cd ".(get "base_dir")."/src/httpd-".(get "apache_version")." && ".
	  "./configure --prefix=".(get "base_dir")."/apache --enable-so --with-ssl --enable-cgi --enable-modules=all --enable-mods-shared=all --enable-ssl --enable-cache --enable-mem-cache && ".
	    "make && make install";
	
	# cleanup
	say "Removing source from system...";
	run "rm -rf ".(get "base_dir")."/src/*";
	
	say "Done.";
};

###
# write Apache configuration to server
desc "Configure Apache webserver";
task "config_apache", group => 'servers', sub {
	# write httpd.conf
	my $filename = (get "base_dir")."/apache/conf/httpd.conf";
	say "Writing file ".$filename;
	file $filename, owner => (get "apache_user"), group => (get "apache_group"), mode => '644',
	  content => template("files/operation/apache/conf/httpd.conf", conf => {
										 apache_root => ((get "base_dir")."/apache"),
										 apache_port => (get "apache_port"),
										 apache_user => (get "apache_user"),
										 apache_group => (get "apache_group"),
										 apache_admin_email => (get "admin_email"),
										 apache_domain => (get "domain"),	
										});

	my $vhosts_dir = (get "base_dir")."/apache/conf/vhosts.d";
	my $extras_dir = (get "base_dir")."/apache/conf/extras.d";
	file $vhosts_dir, ensure => "directory", owner => (get "apache_user"), group => (get "apache_group");
	file $extras_dir, ensure => "directory", owner => (get "apache_user"), group => (get "apache_group");

	# write vhost configuration
	my $vhosts_tmp = get "apache_vhosts";
	my %vhosts = %{$vhosts_tmp};
	foreach my $domain (keys %vhosts) {
		my $vhost_base = $vhosts{$domain};
		my $htdocs_dir = $vhost_base."/htdocs";
		my $logs_dir = $vhost_base."/logs";
		
		# make sure the needed vhosts directories exists
		say "Looking for needed directories and creating them if needed...";
		file $htdocs_dir, ensure => "directory", owner => (get "apache_user"), group => (get "apache_group");
		file $logs_dir, ensure => "directory", owner => (get "apache_user"), group => (get "apache_group");

		say "Creating VirtualHost for $domain with DocumentRoot $htdocs_dir...";
		# print $domain." -> ".$vhosts{$domain}."\n";
		my $vhosts_file = (get "base_dir")."/apache/conf/vhosts.d/".$domain.".conf";
		file $vhosts_file, owner => (get "apache_user"), group => (get "apache_group"), mode => "644",
		  content => template("files/operation/apache/conf/vhosts.d/vhost.conf", conf => {
												  apache_port => (get "apache_port"),
												  vhost_domain => $domain,
												  admin_email => (get "admin_email"),
												  vhost_base => $vhost_base,
												 });
	}

	say "Done.";
};

###
# remove Apache webserver
desc "Uninstall Apache webserver";
task "uninstall_apache", group => 'servers', sub {
	say "Removing Apache webserver...";
	say run "rm -rf ".(get "base_dir")."/apache";
	say "Done.";
};

1;
