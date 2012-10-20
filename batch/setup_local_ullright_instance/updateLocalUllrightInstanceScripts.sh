#!/bin/bash
#
# By Klemens Ullmann-Marx 2012-20-20

echo
echo Update the scripts for local ullright instance handling
echo

cd /usr/local/bin

echo Getting/updating scripts
wget https://raw.github.com/ullright/partners/master/batch/setup_local_ullright_instance/setupLocalUllrightInstance.sh
wget https://raw.github.com/ullright/partners/master/batch/setup_local_ullright_instance/removeLocalUllrightInstance.sh

if [ ! -f /usr/local/bin/setupLocalUllrightInstance.sh.cfg ]
then
  echo No configuration file found. Downloading...
  wget https://raw.github.com/ullright/partners/master/batch/setup_local_ullright_instance/setupLocalUllrightInstance.sh.cfg
  echo 
  echo Please edit the configuration file /usr/local/bin/setupLocalUllrightInstance.sh.cfg
fi

echo "Done!"

