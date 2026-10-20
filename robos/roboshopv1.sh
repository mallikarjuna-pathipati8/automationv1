#!/bib/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="arjundaws92s.store"
hosted_zone_id="Z08325212T4ZKWPRKKKQC"

for instance in $@
do 
   echo "Creating Instance : ${instance}"
done