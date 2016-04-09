#!/bin/bash

# to execute:  bash cleanup_for_test.sh
echo "deleting log files"
rm ./log/*.log

echo "deleting tmp folder"
rm -rf ./tmp

echo "deleting public/tmp folder"
rm -rf ./public/tmp

RAILS_ENV=test rake db:drop
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake testprep:load_data
