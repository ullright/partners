#!/bin/bash
#
# By Klemens Ullmann-Marx 2012-08-08
# By Klemens Ullmann-Marx 2012-20-18
# By Klemens Ullmann-Marx 2012-20-20

# Validate script arguments
# "-z" = "string is empty"
if [ -z "$2" ] || [ -z "$1" ]; then
    echo
    echo Setup a customer ullright instance on the local dev machine
    echo
    echo Usage: sudo `basename $0` name password
    echo - name: the name of the ullright project using dashes as separator \(without ullright_ prefix\)
    echo - password: the password for shell and database
    echo Example: sudo `basename $0` "my-project" "secret123" 
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

# Global configuration

NAME=$1
PASSWORD=$2

UNDERSCORENAME=`echo $NAME | sed s/-/_/g`
ULLRIGHTNAME="ullright_$UNDERSCORENAME"

SVNPATH="http://bigfish.ull.at/svn/ullright_$NAME/trunk"


echo "Creating hosts entry"
echo "127.0.0.1       $ULLRIGHTNAME" >> /etc/hosts

echo "Creating apache vhost"
cat /etc/apache2/sites-available/ullright_example | sed "s/example/$NAME/g" > /etc/apache2/sites-available/$ULLRIGHTNAME
a2ensite $ULLRIGHTNAME
apachectl restart

echo "Creating database $UNDERSCORENAME"
mysql -u $MYSQLUSER --password=$MYSQLPASS --execute "CREATE DATABASE $UNDERSCORENAME;"
mysql -u $MYSQLUSER --password=$MYSQLPASS --execute "GRANT ALL ON $UNDERSCORENAME.* TO $UNDERSCORENAME@localhost IDENTIFIED BY '$PASSWORD';"
mysql -u $MYSQLUSER --password=$MYSQLPASS --execute "flush privileges;"

echo "Creating project dir"
cd /var/www
mkdir $ULLRIGHTNAME
cd $ULLRIGHTNAME

echo "Checking out from svn"
svn checkout $SVNPATH/ .


echo "Configuring custom debug email address in app.yml"
cp apps/frontend/config/app.yml apps/frontend/config/app.yml.99
cat apps/frontend/config/app.yml.99 | sed "s/debug_address:  dev@example.com/debug_address:  $EMAIL/g" > apps/frontend/config/app.yml
rm  apps/frontend/config/app.yml.99

echo "Configuring custom debug email address in app.local.yml"
cp apps/frontend/config/app.local.yml.dist apps/frontend/config/app.local.yml.99
cat apps/frontend/config/app.local.yml.99 | sed "s/debug_address:  dev@example.com/debug_address:  $EMAIL/g" > apps/frontend/config/app.local.yml
rm  apps/frontend/config/app.local.yml.99
svn propset svn:ignore "app.local.yml" apps/frontend/config/
svn commit -m "Tweaking app.yml"


echo "Doing complete refresh"
batch/refresh_completely

echo "Correcting file owner"
chown -R $USER:$USER /var/www/$ULLRIGHTNAME

echo "Done!"
