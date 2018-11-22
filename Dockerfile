
FROM centos:7

# Enable the EPEL repo. The repo package is part of centos base so no need fetch it.
RUN yum -y install epel-release

# Fetch and enable the RPMFusion repo
RUN yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm

# Install the latest *release* of zoneminder
RUN yum -y install zoneminder mod_ssl zip file mariadb

# Set our volumes before we attempt to configure apache
VOLUME /var/lib/zoneminder/images /var/lib/zoneminder/events /var/lib/mysql /var/log/zoneminder

# Configure Apache
RUN ln -sf /etc/zm/www/zoneminder.conf /etc/httpd/conf.d/
RUN echo "ServerName localhost" > /etc/httpd/conf.d/servername.conf
RUN echo -e "# Redirect the webroot to /zm\nRedirectMatch permanent ^/$ /zm" > /etc/httpd/conf.d/redirect.conf

	
# Get the entrypoint script and make sure it is executable
COPY scripts/entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh

COPY scripts/startzm.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/startzm.sh

# Set the Events and Images folder (Useful for running on a volume)
RUN mkdir -p /srv/zoneminder/events && \
    mkdir -p /srv/zoneminder/images && \
    chown -R apache:apache /srv/zoneminder


RUN echo  $'\n\
  ZM_DIR_EVENTS=/srv/zoneminder/events\n\
  ZM_DIR_IMAGES=/srv/zoneminder/images'\
  > /etc/zm/conf.d/volume.conf

# This is run each time the container is started
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
