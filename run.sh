#!/bin/bash
DBDIR=/var/lib/mysql/opengts
if [ ! -d "$DBDIR" ]; then
    sed -i 's/#db.sql.rootUser=root/db.sql.rootUser=root/' $GTS_HOME/common.conf
    sed -i "s/#db.sql.rootPass=rootpass/db.sql.rootPass=$MYSQL_ENV_MYSQL_ROOT_PASSWORD/" $GTS_HOME/common.conf
    sed -i "s/db.sql.host=localhost/db.sql.host=$MYSQL_PORT_3306_TCP_ADDR/" $GTS_HOME/common.conf
    update-rc.d mysql enable
fi
service mysql start
cd $GTS_HOME; ant all
if [ ! -d "$DBDIR" ]; then
    $GTS_HOME/bin/initdb.pl -rootPass=$MYSQL_ENV_MYSQL_ROOT_PASSWORD
    $GTS_HOME/bin/dbAdmin.pl -tables=ca
    $GTS_HOME/bin/admin.sh Account -account=sysadmin -nopass -create
fi
cp $GTS_HOME/build/*.war $CATALINA_HOME/webapps/
$CATALINA_HOME/bin/catalina.sh run

