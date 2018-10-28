#!/bin/bash

domain=$1

# Check if the user is running as root or sudo
if (( UID != 0 )); then
    printf >&2 'You should run this as root/sudo\n'
    exit 1
fi


# Get user input:
while [ "$domain" == "" ]
do
	echo -e $"Provide a domain. e.g. domain.lan or Ctrl+c to quit."
	read domain
done


# Set the path to the document root
documentRoot='/var/www/'$domain'/public_html'


# Create the directory to store the files
mkdir -p $documentRoot

# Set permissions and assign permissions to the current user. Note: $SUDO_USER works on sudo supported systems. Try sudo bash -c 'echo $SUDO_USER' You can also hard code your username if you want. 
chown -R $SUDO_USER:www-data $documentRoot

# Write this to Apache's sites-available.conf
> '/etc/apache2/sites-available/'$domain'.conf' cat <<EOF
<VirtualHost *:80>

	ServerName $domain
	ServerAlias www.$domain
	ServerAdmin webmaster@localhost
	DocumentRoot $documentRoot

	#LogLevel info ssl:warn

	ErrorLog \${APACHE_LOG_DIR}/error.log
	#CustomLog \${APACHE_LOG_DIR}/access.log combined

	#Include conf-available/serve-cgi-bin.conf

	<Directory $documentRoot >
		Options Indexes FollowSymLinks MultiViews
		# AllowOverride All allows using .htaccess
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>

</VirtualHost>
EOF


# a2ensite, a2dissite - enable or disable an apache2 site / virtual host
a2ensite $domain'.conf'


# Append your domain to /etc/hosts
echo -e "127.0.0.1\t"$domain >> /etc/hosts


# Restart apache
service apache2 restart
