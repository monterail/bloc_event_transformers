#!/usr/bin/env bash
set -euo pipefail
command -v node >/dev/null || { echo 'The GitHub writer feature requires Node in the repository base image.' >&2; exit 1; }
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git gh ca-certificates
rm -rf /var/lib/apt/lists/*
install -m 0755 publish.mjs /usr/local/bin/montecito-github-pr
