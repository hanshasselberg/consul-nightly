#!/bin/bash
 
set -e
set -x

revision=$1
name="darwin-amd64-osx10.8"
 
if [[ ! -d go ]]; then
  curl -s -L http://golang.org/dl/go1.4.${name}.tar.gz -O
  tar xvzf go1.3.3.${name}.tar.gz &> /dev/null
fi
 
export GOROOT=`pwd`/go
export GOPATH=`pwd`/gopath
export PATH="`pwd`/go/bin":$PATH
 
if [[ -d $GOPATH ]]; then
  cd $GOPATH/src/github.com/hashicorp/consul
  git pull
else
  mkdir -p $GOPATH/src/github.com/hashicorp/
  git clone git@github.com:hashicorp/consul.git $GOPATH/src/github.com/hashicorp/consul
  cd $GOPATH/src/github.com/hashicorp/consul
fi

git reset --hard $revision
 
go get -u ./...
make
echo "`pwd`/bin/consul"
AWS_DEFAULT_REGION=eu-west-1 aws s3 cp --acl public-read "`pwd`/bin/consul" s3://consul-nightly/$revision/darwin-amd64 --profile hans.io
