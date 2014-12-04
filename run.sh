#!/bin/bash

set -e
set -x

revision=$1

function build {
  ami=$1
  name=$2
  id=`aws ec2 run-instances --image-id $ami \
    --count 1 --instance-type t1.micro --key-name id_aws_hans \
    --security-groups consul-nightly \
    --iam-instance-profile Name=consul-nightly \
    --profile hans.io \
    | jq -r '.Instances[].InstanceId'`

  while true; do
    dns=`aws ec2 describe-instances --instance-ids $id --profile hans.io \
      | jq -r '.Reservations[].Instances[].PublicDnsName'`
    if [[ "$dns" != "null" && "$dns" != "" ]]; then 
      break
    fi;
    sleep 10;
  done

  echo $dns
  while true; do
    ssh -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@$dns "true" && break;
    sleep 10;
  done

  scp build.sh ubuntu@$dns:.
  ssh ubuntu@$dns ./build.sh $revision $name

  aws ec2 terminate-instances --instance-ids $id --profile hans.io
  echo "Done with $name"
}

build "ami-0ab1117d" "linux-386"
build "ami-f6b11181" "linux-amd64"

. build_local.sh
