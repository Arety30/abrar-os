#!/usr/bin/env bash
# copy airootfs/ overlay onto / (idempotent), fix perms, make symlinks
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
rsync -a --no-owner --no-group "$HERE/airootfs/" /
chmod 755 /usr/local/bin/*
chmod 440 /etc/sudoers.d/*
for s in adduser deluser; do ln -sfn dyverz-adduser /usr/local/bin/$s; done
ln -sfn dyverz-exe-install /usr/local/bin/install-exe
mkdir -p /var/lib/winkernel /mnt/cdrive
