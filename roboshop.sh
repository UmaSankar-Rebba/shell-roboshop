#!/bin/bash
SG_ID="sg-0c2d3e7831a625405"
AMI_ID="ami-0220d79f3f480ecf5"
R="\e[31m"
N="\e[0m"

for instance in "$@"
do
instance_id=$(aws ec2 run-instances \
 --image-id $AMI_ID \
 --instance-type t3.micro \
 --security-group-ids $SG_ID \
 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
 --query 'Instances[0].InstanceId' \
 --output text )   

if [ $instance == "frontend" ]; then
 IP=$( aws ec2 describe-instances \
 --instance-ids $instance_id \
 --query "Reservations[].Instances[].PublicIpAddress" \
 --output text
  )
else
 IP=$(
    aws ec2 describe-instances \    --instance-ids $instance_id \
 --query "Reservations[].Instances[].PrivateIpAddress" \
 --output text
 )
fi
echo -e " $R Your IP Address is $IP $N"
done
