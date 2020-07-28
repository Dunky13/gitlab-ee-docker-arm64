# Build and Install Gitlab for Arm64 Devices

If you just want to install Gitlab Arm 64, you can use my prebuild package at [here](https://gitlab.com/gypsophlia/gitlab-build-arm64/-/tree/master/release), and skip to *Deploy the package in Docker* section

or pre-build docker image for arm64 devices by running: `docker pull registry.gitlab.com/gypsophlia/omnibus-gitlab/gitlab-ce:13.1.2-ce.0_arm64`

## Setp 1: Setup AWS ARM64 instance
If you don't like coress compile, you can request a `a1.4xlarge`
 spot instance on AWS, please remember to increace the storage space when requesting. I set it to 30GB

### Spot Instance Config
* Instance Type: a1.4xlarge
* AMI: debian-10-arm64-daily-20191116-79 (ami-0003093ba0257bece)
* Storage: 30GB

### Install docker-ce and git on AWS instance
```bash
sudo apt update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common git -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce -y
```

## Step 2: Build gitlab-omnibus-builder docker

If you want to build the gitlab-omnibus-builder image by yourself, please use this branch: 

`https://gitlab.com/gypsophlia/gitlab-omnibus-builder/-/tree/ubuntu20.04-arm64`

And build using the following commands:

```bash
git clone https://gitlab.com/gypsophlia/gitlab-omnibus-builder.git
cd gitlab-omnibus-builder/
git checkout ubuntu20.04-arm64
cd docker/
sudo docker build -f Dockerfile_ubuntu_20.04_arm64 -t gitlab-omnibus-builder/ubuntu20.04-arm64 .
```

Or you can download pre-build image using this command: 

```bash
sudo docker pull registry.gitlab.com/gypsophlia/gitlab-omnibus-builder/ubuntu20.04-arm64
```

## Step 3: Build Gitlab CE Package

Start the container and enter its shell:

```bash
sudo docker run -it  registry.gitlab.com/gypsophlia/gitlab-omnibus-builder/ubuntu20.04-arm64 bash
```

Run the following command inside the container:

```bash
git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git ~/omnibus-gitlab
cd ~/omnibus-gitlab
export ALTERNATIVE_SOURCES=true
export COMPILE_ASSETS=true
git checkout 13.1.2+ce.0
bundle install --path .bundle --binstubs
bin/omnibus build gitlab
```

You can see the results of the build in the pkg folder at the root of the
source tree.

It will take **2-3 hours** for the build to finish. 

Note: `COMPILE_ASSETS=true` is set to be true, I was haveing some error when not setting this. However this will make increase the time of building the package

## Deploy the package in Docker
1. clone the omnibus-gitlab repo: `git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git` 
2. Change `FROM ubuntu:16.04` to `FROM ubuntu:20.04` in `omnibus-gitlab/docker/Dockerfile`
3. Copy the build result(.deb package) to `omnibus-gitlab/docker/assets`
4. Comment out/delete all content in `omnibus-gitlab/docker/assets/download-package` and add `cp /assets/gitlab-ce_13.1.2-ce.0_arm64.deb /tmp/gitlab.deb`. (`gitlab-ce_13.1.2-ce.0_arm64.deb` is the build result from Step 3)
5. create an empty RELEASE file `touch omnibus-gitlab/docker/RELEASE`
6. run `sudo docker build -f ./Dockerfile -t gitlab-ce .` in `omnibus-gitlab/docker/`folder to build the package

This has been tested on [Odroid C4](https://www.hardkernel.com/shop/odroid-c4/), but it should work on other Arm64 platforms. 

I have some prebuild package for arm64 at [here](https://gitlab.com/gypsophlia/gitlab-build-arm64/-/tree/master/release) 

## Reference
1. [prepare-build-environment.md](https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/13.1.2+ce.0/doc/build/prepare-build-environment.md)