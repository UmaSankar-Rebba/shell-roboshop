#!/bin/bash
SG_ID="sg-0c2d3e7831a625405"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z06532621BV9L2WWM6NW4"
DOMAIN_NAME="rebba.online"
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
  RECORD_NAME="$DOMAIN_NAME" #rebba.online
else
 IP=$(
    aws ec2 describe-instances \
 --instance-ids $instance_id \
 --query "Reservations[].Instances[].PrivateIpAddress" \
 --output text
 )
RECORD_NAME="$instance.$DOMAIN_NAME" #backend.rebba.online
fi
echo -e " $R Your IP Address is $IP $N"

aws route53 change-resource-record-sets \
 --hosted-zone-id $ZONE_ID \
 --change-batch '
 {
  "Comment": "Update record to reflect new IP address",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
        ]
      }
    }
  ]
}
'
echo "record updated for $instance"
done
