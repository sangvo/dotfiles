#!/usr/bin/env bash
# Run bootstrap.sh twice in a fresh Ubuntu 24.04 container and check the result.
# Needs a Docker daemon. PLATFORM defaults to linux/amd64 to match x86 machines.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PLATFORM=${PLATFORM:-linux/amd64}

docker run --rm --platform "$PLATFORM" -v "$REPO_ROOT:/src:ro" ubuntu:24.04 bash -euo pipefail -c '
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sudo git ca-certificates curl bsdutils >/dev/null
  useradd --create-home --shell /bin/bash dev
  echo "dev ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dev
  install -d -o dev -g dev /home/dev/workspace
  cp -a /src /home/dev/workspace/dotfiles
  chown -R dev:dev /home/dev/workspace/dotfiles
  su - dev -c "bash /home/dev/workspace/dotfiles/tests/ubuntu-checks.sh"
'
