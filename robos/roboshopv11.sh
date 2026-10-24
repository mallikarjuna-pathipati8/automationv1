#!/bib/bash
ami-id="ami-0055977a6e828a4f4"
instance-type="t3.micro"
domain-name="arjundaws92s.store"
hosted-zone-id="Z08325212T4ZKWPRKKKQC"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

for instance in $@
do
    echo "Installing instance is :${instance}"
    instance-id=$(aws ec2 run-instances \
  --image-id "$ami-id" \
  --instance-type "$instance-type" \
  --security-groups "roboshop-common" "$instance"\
  --query 'Instances[0].InstanceId' \
  --output text)
  
done
echo "instance id :${instance-id}"