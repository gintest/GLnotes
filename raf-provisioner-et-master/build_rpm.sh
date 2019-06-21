#!/bin/bash

pushd "$(dirname "$0")"

shopt -s extglob

COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B | head -1)

echo "Commit hash: $COMMIT_HASH" >> metadata.txt
echo "Commit message: $COMMIT_MSG" >> metadata.txt

rm -rf .package || true

mkdir -p .package/etc/reflex-provisioner-et/ dist

git log --pretty=format:"%h%x09%an%x09%ad%x09%s" | head -n 10 > ./.gitlog
cp -r !(build_rpm.sh|dist|id_rsa*) .package/etc/reflex-provisioner-et/

fpm  -f -s dir -t rpm --rpm-os linux -v $1 --iteration $2 --chdir .package -p dist --url http://guavus.com --description "commit_hash=$COMMIT_HASH;commit_msg=$COMMIT_MSG"  -n reflex-provisioner-et .
