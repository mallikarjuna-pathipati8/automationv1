#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="arjundaws92s.store"
hosted_zone_id="Z08325212T4ZKWPRKKKQC"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

for instance in $@
do
    echo "Installing instance is :${instance}"
    instance_id=$(aws ec2 run-instances \
      --image-id "$ami_id" \
      --instance-type "$instance_type" \
      --security-groups "roboshop-common" "roboshop-$instance" \
      --query 'Instances[0].InstanceId' \
      --output text
  )
  echo "instance id :${instance_id}"
done
