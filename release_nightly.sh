#!/bin/bash
#if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
  echo -e "releasing nightly...\n"

  cd $HOME
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  git clone --quiet --branch=master https://${GH_TOKEN}@github.com/SzFMV2018-Tavasz/release-test master > /dev/null
  cd master
#  mvn clean compile assembly:single
#  cp target/release-test-jar-with-dependencies.jar target/release-test.jar
  tag="$(date +'%Y-%m-%d')-$(git log --format=%h -1)"

  git tag $tag

  git push -fq origin $tag

  echo -e "release added\n"
#fi