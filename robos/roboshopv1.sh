#!/bin/bash
    ami_id="ami-0055977a6e828a4f4"
    instance_type="t3.micro"
    domain_name="arjundaws92s.store"
    hosted_zone_id="Z08325212T4ZKWPRKKKQC"

    R="\e[31m"
    G="\e[32m"
    Y="\e[33m"
    N="\e[0m"

    for instance in "$@"
    do
        echo -e "${Y}Installing instance is :${instance}${N}"
        instance_id=$(aws ec2 run-instances \
          --image-id "$ami_id" \
          --instance-type "$instance_type" \
          --security-groups "roboshop-common" "roboshop-$instance" \
          --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
          --query 'Instances[0].InstanceId' \
          --output text
      )
      echo -e "${G}instance id :${instance_id}${N}"

      if [ "$instance" != "frontend" ]; then
                IP=$(aws ec2 describe-instances \
                  --instance-ids $instance_id  \
                  --query 'Reservations[*].Instances[*].PrivateIpAddress' \
                  --output text)
                  r53_record=$instance.$domain_name
                  echo -e "${G}r53_record : ${r53_record}${N}"
        else 
                IP=$(aws ec2 describe-instances \
                  --instance-ids $instance_id  \
                  --query 'Reservations[*].Instances[*].PublicIpAddress' \
                  --output text)
                  r53_record=$domain_name
                  echo -e "${G}r53_record : ${r53_record}${N}"
      fi
      aws route53 change-resource-record-sets \
      --hosted-zone-id "${hosted_zone_id}" \
      --change-batch '{
        "Changes": [
          {
            "Action": "UPSERT",
            "ResourceRecordSet": {
              "Name": "'$r53_record'",
              "Type": "A",
              "TTL": 1,
              "ResourceRecords": [{"Value": "'$IP'"}]
            }
          }
        ]
      }'       
    echo -e "${Y} Updated ${r53_record} in Hosted Zone ${hosted_zone_id} and ${instance_id}${N}"
    done
