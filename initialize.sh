#!/bin/bash

set -e

SAMPLE_DATA_FILE=/magento_sample_data*.sql
MYSQL="mysql -h db -u$MYSQL_USER -p$MYSQL_PASSWORD"
MYSQLDB="mysql -h db -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE"

if [ -f $SAMPLE_DATA_FILE -a -n "$MYSQL_DATABASE" ] ; then
	# The init sql file is still lying around. This means we have not inited the db
	# Do it now.

	# ensure they gave us a db/user/password to connect, otherwise show error
	if [ -z "$MYSQL_USER" -o -z "$MYSQL_PASSWORD" -o -z "$MYSQL_DATABASE"  ]; then
		echo >&2 "Database is not initialized. To do so, please supply the following:"
		echo >&2 "    MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE"
		echo >&2 "as env vars, eg, -e 'MYSQL_USER=root'"
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
fi

# We no longer need the sql file.
rm $SAMPLE_DATA_FILE

exec "$@"

