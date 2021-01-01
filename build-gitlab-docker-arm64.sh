#!/bin/bash

VERSION=13.7.1
# Replace BASE_URL and VERSION when the official arm64 package is available
BASE_URL=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/focal/


git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git
cd omnibus-gitlab
git checkout $VERSION+ee.0

sed 's/FROM\ ubuntu:16.04/FROM\ ubuntu:20.04/g' ./docker/Dockerfile > ./docker/Dockerfile_ubuntu_20.04
echo "RELEASE_PACKAGE=gitlab-ee" > ./docker/RELEASE
echo "RELEASE_VERSION=$VERSION-ee.0" >> ./docker/RELEASE
echo "DOWNLOAD_URL=$BASE_URL/gitlab-ee_$VERSION-ee.0_arm64.deb/download.deb" >> ./docker/RELEASE

sudo docker build -f ./docker/Dockerfile_ubuntu_20.04 -t gitlab/gitlab-ee:$VERSION-ee.0 --platform linux/arm64 ./docker/
