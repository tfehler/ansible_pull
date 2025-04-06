#!/bin/bash
set -e

REPO_URL="https://github.com/TimFehler/ansible_workstation.git"
DEST="$HOME/.ansible-pull"

ansible-pull -U "$REPO_URL" -d "$DEST" -i localhost, -e ansible_hostname=$(hostname) pull.yml
