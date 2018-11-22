#!/bin/bash

# Subroutines
# Return status of mysql service
mysql_running () {
    mysqladmin ping -u${ZM_DB_USER} -p${ZM_DB_PASS} -h${ZM_DB_HOST} > /dev/null 2>&1
    local result="$?"
    if [ "$result" -eq "0" ]; then
        echo "1" # mysql is running
    else
        echo "0" # mysql is not running
    fi
}

zm_db_exists() {
    mysqlshow -u${ZM_DB_USER} -p${ZM_DB_PASS} -h${ZM_DB_HOST} ${ZM_DB_NAME} > /dev/null 2>&1
    RETVAL=$?
    if [ "$RETVAL" = "0" ]; then
        echo "1" # ZoneMinder database exists
    else
        echo "0" # ZoneMinder database does not exist
    fi
}
# Check the status of the remote mysql server using supplied credentials

# Look in common places for the zoneminder dB creation script - zm_create.sql
for FILE in "/usr/share/zoneminder/db/zm_create.sql" "/usr/local/share/zoneminder/db/zm_create.sql"; do
    if [ -f $FILE ]; then
        ZMCREATE=$FILE
        break
    fi
done
chk_remote_mysql () {
        echo -n " * Looking for remote database server"
        if [ "$(mysql_running)" -eq "1" ]; then
            echo "   ...found."
            echo -n " * Attempting to create remote database using provided credentials"
            mysql -u${ZM_DB_USER} -p${ZM_DB_PASS} -h${ZM_DB_HOST} < $ZMCREATE > /dev/null 2>&1
            RETVAL=$?
            if [ "$RETVAL" = "0" ]; then
                echo "   ...done."
        else
            echo "   ...failed!"
            return
        fi
        fi
}


echo
for FILE in "/etc/php/7.0/apache2/php.ini" "/etc/php5/apache2/php.ini" "/etc/php.ini" "/usr/local/etc/php.ini"; do
    if [ -f $FILE ]; then
        PHPINI=$FILE
        break
    fi
done
# Set the timezone before we start any services
if [ -z "$TZ" ]; then
    TZ="UTC"
fi
echo "date.timezone = $TZ" >> $PHPINI
if [ -L /etc/localtime ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
fi
if [ -f /etc/timezone ]; then
    echo "$TZ" > /etc/timezone
fi
# Look in common places for the zoneminder config file - zm.conf
for FILE in "/etc/zm.conf" "/etc/zm/zm.conf" "/usr/local/etc/zm.conf" "/usr/local/etc/zm/zm.conf"; do
    if [ -f $FILE ]; then
        ZMCONF=$FILE
        break
    fi
done

sed -i -e "s/ZM_DB_NAME=.*$/ZM_DB_NAME=$ZM_DB_NAME/g" $ZMCONF
sed -i -e "s/ZM_DB_USER=.*$/ZM_DB_USER=$ZM_DB_USER/g" $ZMCONF
sed -i -e "s/ZM_DB_PASS=.*$/ZM_DB_PASS=$ZM_DB_PASS/g" $ZMCONF
sed -i -e "s/ZM_DB_HOST=.*$/ZM_DB_HOST=$ZM_DB_HOST/g" $ZMCONF
sleep 20 # In case the healthcheck hasn't worked we'll wait....
chk_remote_mysql


# Ensure we shutdown our services cleanly when we are told to stop
trap cleanup SIGTERM


# # Start ZoneMinder
echo "===>   Starting ZoneMinder....."
/usr/bin/zmpkg.pl start

# Hook for custom script in child images
if [[ -f /usr/local/bin/custom.sh ]]; then
  /usr/local/bin/custom.sh $CUSTOM_ARGS
fi

# Handoff to application process
# exec "$@"
echo "===>   Starting apache....."
./usr/sbin/httpd -DFOREGROUND
