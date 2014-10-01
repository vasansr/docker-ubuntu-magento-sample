#!/bin/bash

echo "Starting apache server"
source /etc/apache2/envvars
exec apache2 -D FOREGROUND
