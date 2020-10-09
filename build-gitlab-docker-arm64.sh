#!/bin/bash
VERSION=13.4.0

# Replace BASE_URL and VERSION when the official arm64 package is available
BASE_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/focal/gitlab-ce_$(VERSION)-ce.0_arm64.deb/download.deb


git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git
cd omnibus-gitlab
git checkout $VERSION+ce.0

sed 's/FROM\ ubuntu:16.04/FROM\ ubuntu:20.04/g' ./docker/Dockerfile > ./docker/Dockerfile_ubuntu_20.04
echo "RELEASE_PACKAGE=gitlab-ce" > ./docker/RELEASE
echo "RELEASE_VERSION=$VERSION-ce.0" >> ./docker/RELEASE
echo "DOWNLOAD_URL=$BASE_URL/gitlab-ce_$VERSION-ce.0_arm64.deb" >> ./docker/RELEASE

sudo docker build -f ./docker/Dockerfile_ubuntu_20.04 -t gitlab/gitlab-ce:$VERSION-ce.0 --platform linux/arm64 ./docker/
