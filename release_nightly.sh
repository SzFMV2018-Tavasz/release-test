#!/bin/bash
if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
  mvn clean compile assembly:single
  cp target/release-test-jar-with-dependencies.jar target/release-test.jar
  echo -e "releasing nightly...\n"
  ruby release_nightly.rb $GH_TOKEN
  echo -e "release added\n"
fi
