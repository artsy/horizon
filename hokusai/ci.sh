#!/bin/sh

set -ex

sleep 1 # wait for postgres :(
bundle exec rails db:prepare
bundle exec rake spec
