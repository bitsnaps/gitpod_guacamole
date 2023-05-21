#!/bin/bash

# Update system and install required build tools
sudo apt-get update
sudo apt-get install -y make gcc g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libssl-dev libvorbis-dev libwebp-dev

# Download and extract Guacamole server
GUAC_VERSION="1.4.0"
wget https://downloads.apache.org/guacamole/$GUAC_VERSION/source/guacamole-server-$GUAC_VERSION.tar.gz
tar -xvf guacamole-server-$GUAC_VERSION.tar.gz
cd guacamole-server-$GUAC_VERSION

# Configure, compile, and install Guacamole server
./configure --with-init-dir=/etc/init.d
sudo make
sudo make install
sudo ldconfig

# Start and enable Guacamole daemon
sudo systemctl start guacd
sudo systemctl enable guacd
sudo systemctl status guacd

# Create guacamole.properties file
sudo mkdir -p /etc/guacamole
cat << EOF | sudo tee /etc/guacamole/guacamole.properties
guacd-hostname: localhost
guacd-port:     4822
user-mapping:   /etc/guacamole/user-mapping.xml
auth-provider:  net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOF

# Create user-mapping.xml file with your desired username and password
USERNAME="yourUsername"
PASSWORD="yourStrongPassword"
HASHED_PASSWORD=$(echo -n $PASSWORD | openssl md5)
cat << EOF | sudo tee /etc/guacamole/user-mapping.xml
<user-mapping>
    <authorize 
            username="$USERNAME"
            password="$HASHED_PASSWORD"
            encoding="md5">
        <!-- Add your connections here -->
    </authorize>
</user-mapping>
EOF


