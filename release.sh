#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit
npm run docs
npm run compile
git add .
git commit -m "$1"
