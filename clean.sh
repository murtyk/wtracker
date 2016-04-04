#!/bin/bash

# to execute:  bash cleanup_for_test.sh
echo "deleting log files"
rm ./log/*.log

echo "deleting tmp folder"
rm -rf ./tmp

echo "deleting public/tmp folder"
rm -rf ./public/tmp

sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS wtracker_test;"
sudo -u postgres psql postgres -c "CREATE DATABASE wtracker_test WITH ENCODING 'UTF8' TEMPLATE wtracker_test3"
