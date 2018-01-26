#! /bin/bash
set -e

shellcheck ./*.sh
yamllint ./*.yml roles/*/*/*.yml
