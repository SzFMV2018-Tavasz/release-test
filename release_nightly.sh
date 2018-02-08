#!/bin/bash
# if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
  mvn clean compile assembly:single
  cp target/release-test-jar-with-dependencies.jar target/release-test.jar
  
  cd $HOME
  # git config --global user.email "travis@travis-ci.org"
  # git config --global user.name "travis-ci"
  git clone --quiet --branch=master "https://jartenmaa:$GH_TOKEN@github.com/SzFMV2018-Tavasz/release-test" master > /dev/null

  cd master
  git remote set-url origin "https://jartenmaa:$GH_TOKEN@github.com/SzFMV2018-Tavasz/release-test.git" > /dev/null
  git tag -d nightly
  git push origin :refs/tags/nightly
  
  echo -e "releasing nightly...\n"
  ruby release_nightly.rb $GH_TOKEN
  echo -e "release added\n"
# fi
