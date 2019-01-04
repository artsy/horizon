#!/bin/sh

set -ex

sleep 1 # wait for postgres :(
bundle exec rake db:setup spec
