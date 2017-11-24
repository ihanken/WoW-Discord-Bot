#!/bin/bash
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
    # This runs when a pull request is submitted.
    bash ./travis/run_tests.sh
    exit $?
fi

if [[ "$TRAVIS_BRANCH" == "develop" ]]; then
    # This runs on a merge into develop.
    bash ./travis/upload_development_container.sh
    exit $?
fi

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    # This runs on a merge into master.
    bash ./travis/upload_production_container.sh
    exit $?
fi