#!/bin/bash
# if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
  mvn clean compile assembly:single
  cp target/release-test-jar-with-dependencies.jar target/release-test.jar
  
  cd $HOME
  # git config --global user.email "travis@travis-ci.org"
  # git config --global user.name "travis-ci"
  if  [ "$GH_TOKEN" == "" ]; then
    echo "no token"
  fi
  git clone --quiet --branch=master "https://jartenmaa:${GH_TOKEN}@github.com/SzFMV2018-Tavasz/release-test" master > /dev/null

  cd master
  git config user.email "31477235+jartenmaa@users.noreply.github.com"
  git config user.name "jartenmaa"
  git remote set-url origin "https://jartenmaa:${GH_TOKEN}@github.com/SzFMV2018-Tavasz/release-test.git" > /dev/null
  git tag -d nightly
  git push -q origin :refs/tags/nightly
  
  echo -e "releasing nightly...\n"
  ruby release_nightly.rb $GH_TOKEN
  echo -e "release added\n"
# fi
