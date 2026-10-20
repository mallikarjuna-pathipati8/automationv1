#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="arjundaws92s.store"
hosted_zone_id="Z08325212T4ZKWPRKKKQC"

for instance in "$@"
do
    echo "Creating instance: $instance"

    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --security-groups "roboshop-common" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

    echo "$instance ID: $instance_id"
done