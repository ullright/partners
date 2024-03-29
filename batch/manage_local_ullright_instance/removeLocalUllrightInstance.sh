#!/bin/bash
#
# By Klemens Ullmann-Marx 2012-20-20

# Validate script arguments
# "-z" = "string is empty"
if [ -z "$1" ]; then
    echo
    echo Remove a customer ullright instance on the local dev machine
    echo
    echo Usage: sudo `basename $0` name
    echo - name: the name of the ullright project using dashes as separator \(without ullright_ prefix\)
    echo Example: sudo `basename $0` "my-project" 
    echo
    echo Run as root with sudo!
    echo

    # exit with error code
    exit 64
fi

# Include local configuration
source `dirname $0`/manageLocalUllrightInstance.config

# Validate local configuration variables
# "-z" = "string is empty"
if [ -z $UNIXUSER ] || [ -z $EMAIL ] || [ -z $MYSQLUSER ] || [ -z $MYSQLPASS ] ; then
    echo
    echo Required configuration variables not set
    echo Please supply a local configuration file \"manageLocalUllrightInstance.config\" like the following
    echo and make sure all variables are set:
    echo
    echo \# Change to your needs
    echo \#
    echo \# 2012-10-20 by Klemens Ullmann-Marx
    echo 
    echo \# Local unix username
    echo UNIXUSER=\"maria\"
    echo 
    echo \# Your email address
    echo EMAIL=\"maria@manned-spaceflight.com\"
    echo 
    echo \# Local mysql user and password
    echo MYSQLUSER=\"root\"
    echo MYSQLPASS=\"megasecret123\"
    echo 

    # exit with error code
    exit 64
fi

# Confirmation
read -r -p "Would you really like to delete local ullright instance \""$1"\" [Y/n] ? " response
response=${response,,} # tolower

if [[ $response =~ ^(yes|y| ) ]] ;  then
    echo ok, proceeding...
else
    echo ok, aborting...
    exit 64
fi


# Global configuration

NAME=$1

UNDERSCORENAME=`echo $NAME | sed s/-/_/g`
ULLRIGHTNAME="ullright_$UNDERSCORENAME"


echo "Removing hosts entry"
cp /etc/hosts /etc/hosts.99
cat /etc/hosts.99 | sed "s/127.0.0.1       $ULLRIGHTNAME//g" > /etc/hosts
rm  /etc/hosts.99

echo "Removing apache vhost"
a2dissite $ULLRIGHTNAME
apachectl restart
rm /etc/apache2/sites-available/$ULLRIGHTNAME

echo "Remove database $UNDERSCORENAME"
mysql -u $MYSQLUSER --password=$MYSQLPASS --execute "DROP DATABASE $UNDERSCORENAME;"
mysql -u $MYSQLUSER --password=$MYSQLPASS --execute "DROP USER $UNDERSCORENAME@localhost;"
mysql -u $MYSQLUSER --password=$MYSQLPASS --execute "FLUSH PRIVILEGES;"

echo "Remove project dir"
rm -rf /var/www/$ULLRIGHTNAME

echo "Done!"
