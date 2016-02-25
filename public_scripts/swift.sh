#!/bin/bash

aptitude install clang libicu-dev

mkdir /swift
pushd /swift

curl -fLO https://swift.org/builds/ubuntu1404/swift-2.2-SNAPSHOT-2015-12-22-a/swift-2.2-SNAPSHOT-2015-12-22-a-ubuntu14.04.tar.gz
curl -fLO https://swift.org/builds/ubuntu1404/swift-2.2-SNAPSHOT-2015-12-22-a/swift-2.2-SNAPSHOT-2015-12-22-a-ubuntu14.04.tar.gz.sig

wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -
gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift
gpg --verify swift-2.2-SNAPSHOT-2015-12-22-a-ubuntu14.04.tar.gz.sig

tar xzvf swift-2.2-SNAPSHOT-2015-12-22-a-ubuntu14.04.tar.gz
