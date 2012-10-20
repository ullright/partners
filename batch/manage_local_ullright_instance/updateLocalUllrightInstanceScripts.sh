#!/bin/bash
#
# By Klemens Ullmann-Marx 2012-20-20

echo
echo Update the scripts for local ullright instance handling
echo
echo Run as root using sudo!
echo

cd /usr/local/bin

echo Getting/updating scripts
# -N = overwrite when downloaded file is newer
wget -N https://raw.github.com/ullright/partners/master/batch/manage_local_ullright_instance/setupLocalUllrightInstance.sh
wget -N https://raw.github.com/ullright/partners/master/batch/manage_local_ullright_instance/removeLocalUllrightInstance.sh
wget -N https://raw.github.com/ullright/partners/master/batch/manage_local_ullright_instance/updateLocalUllrightInstanceScripts.sh

if [ ! -f /usr/local/bin/setupLocalUllrightInstance.sh.cfg ]
then
  echo No configuration file found. Downloading...
  wget https://raw.github.com/ullright/partners/master/batch/manage_local_ullright_instance/setupLocalUllrightInstance.sh.cfg
  echo 
  echo Please edit the configuration file /usr/local/bin/setupLocalUllrightInstance.sh.cfg
  echo 
fi

echo "Fixing permissions"
chmod 0700 *LocalUllrightInstance*.sh
chmod 0600 setupLocalUllrightInstance.sh.cfg

echo "Getting/updating example apache vhost file"
cd /etc/apache2/sites-available
wget -N https://raw.github.com/ullright/partners/master/batch/manage_local_ullright_instance/ullright_example

cd `dirname $0` 

echo "Done!"

