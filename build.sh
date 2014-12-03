#!/bin/bash
 
set -e
set -x

revision=$1
name=$2
 
sudo apt-get update &> /dev/null
sudo apt-get --assume-yes --force-yes install git build-essential python-pip libsqlite3-dev &> /dev/null
sudo pip install awscli
curl -L http://golang.org/dl/go1.3.3.$name.tar.gz -O
tar xvzf go1.3.3.$name.tar.gz &> /dev/null
echo "Host github.com" >> ~/.ssh/config
echo " StrictHostKeyChecking no" >> ~/.ssh/config
 
export GOROOT=`pwd`/go
export GOPATH=`pwd`/gopath
export PATH=$PATH:/home/ubuntu/go/bin:$GOPATH/bin
 
mkdir -p $GOPATH/src/github.com/hashicorp/
git clone git@github.com:hashicorp/consul.git $GOPATH/src/github.com/hashicorp/consul
cd $GOPATH/src/github.com/hashicorp/consul
git reset --hard $revision
 
make
echo "`pwd`/bin/consul"
AWS_DEFAULT_REGION=eu-west-1 aws s3 cp --acl public-read "`pwd`/bin/consul" s3://consul-nightly/$revision/$name
