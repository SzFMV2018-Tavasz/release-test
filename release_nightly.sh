#!/bin/bash
#if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
  echo -e "releasing nightly...\n"
  mvn clean compile assembly:single
  cp target/release-test-jar-with-dependencies.jar target/release-test.jar

  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  git tag "$(date +'%Y%m%d%H%M%S')-$(git log --format=%h -1)"

  git push origin Nightly

  echo -e "release added\n"
#fi