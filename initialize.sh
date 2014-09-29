#!/bin/bash

set -e

SAMPLE_DATA_FILE=/var/www/html/magento_sample_data_for_1.9.0.0.sql
MYSQL="mysql -u$MYSQL_USER -p$MYSQL_PASSWORD"
MYSQLDB="mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE"

if [ -f $SAMPLE_DATA_FILE ] ; then
	# The init sql file is still lying around. This means we have not inited the db
	# Do it now.

	# ensure they gave us a db/user/password to connect, otherwise show error
	if [ -z "$MYSQL_USER" -o -z "$MYSQL_PASSWORD" -o -z "$MYSQL_DATABASE"  ]; then
		echo >&2 "Please supply MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE as env vars"
		exit 1
	fi

	# ensure we are able to connect to the db. Must be linked as "db"
	$MYSQL -e status
	if [ $? -ne 0 ] ; then
		echo >&2 "Couldn't connect to db Ensure you have linked the container as 'db'"
		exit 1
	fi

	echo "Initializing the database with sample data"
	$MYSQL -e "CREATE DATABASE $MYSQL_DATABASE"
	$MYSQLDB < $SAMPLE_DATA_FILE
	if [ $? -ne 0 ] ; then
		echo >&2 "Couldn't initialize the DB. Ensure proper permissions have been given"
		exit 1
	fi

	# success: we no longer need the sql file.
	rm $SAMPLE_DATA_FILE
fi

exec "$@"

