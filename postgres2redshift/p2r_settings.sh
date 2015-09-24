#!/bin/sh

### LICENSE
  # Author: Vlad Dubovskiy, November 2014. 
  # License: Copyright (c) This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

# Export $PATH to work with crontab if you need to, example:
# export PATH="/bin/s3cmd-1.5.0-rc1:/usr/local/pgsql/bin"

# SOURCE DB (Postgres) - params are passed as attributes from the command line, see script usage section in README.md
# TARGET DB (Redshift)
RSHOST=redshift.host.name
RSHOSTPORT=5439
RSADMIN=superuser
RSNAME=dbname
RSKEY=aws_key
RSSECRET=aws_secret
RSUSER=some_user # name of the non-superuser! who will get read/write access to your schemas and tables. It's critical that you create this user that is not sudo to avoid concurrent connection limits
RSSCHEMA=sname # target schema on your redshift cluster. You could change this, but public is the default schema.
DBSCHEMA=sname # source schema on your postgres DB. Public is default
TMPSCHEMA=sname
# DIRECTORIES
PGSQL_BIN=/usr/bin # your postgres bin directory. Tested with psql 9.3.1
PYTHONBIN=/usr/bin/python # location of your python 2.7.8 executable. Other python version will likely work as well. We install anaconda distribution. Quick and easy
SCRPTDIR=~/open-data-science/postgres2redshift/scripts
DATADIR=~/open-data-science/postgres2redshift/dumps # a place to store table dumps. Make sure it's larger than all the DB tables of interest
S3BUCKET=sbucket # S3 bucket to which your machine has API read/write privileges to. Must install s3cmd and configure it
# LOGGING
STDERR=/tmp/p2r.err
STDOUT=/tmp/p2r.out
LOCKFILE=/tmp/p2r.lock
# EMAIL NOTIFICATION
RECIPIENT='brianm@motiga.com'
SENDER='brianm@motiga.com'
SUBJECT='Redshift Refresh Failures'

# do not add views or functions to redshift. These are actual names of tables in your Postgres database
#TABLES='table1 table2 table3 table4 table5 table6 table7'

TABLES='game_versions accepted_eulas facebook_links gamecenter_links google_links motiga_links motiga_password_resets users shipping_info eula flags dxdiags locations blocks bounced_emails nominations user_permissions marketing_emails xboxlive_links beta_keys'

# Custom Tables [CT] (some tables are huge due to text data, so you can define custom SQL to either munge your tables or only select certain columns for migration)
# The names of the variables must match actual tables names in the schema. Order commands inside CTSQL list and table names inside CTNAMES list so the indexes of the list match.
# Custom tables must have all the same columns as defined in schema, or you'll have to define a dummy table in your DB or adjust python schema part of the script to accomdate your new table structures
  # If you are just dropping columns (like me), then fill them in with something

## declare an array variable
###declare -a CTSQL=("SELECT id, NULL AS text_data  FROM table8" \
###                "SELECT id, NULL AS more_text_data FROM table9")
###CTNAMES=( table8 table9 )
