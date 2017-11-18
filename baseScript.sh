#!/bin/bash
#########################################################################
# Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
##########################################################################

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

## Colouring works great! TODO: Further formatting.
echo -e "........ ${BIWhite}Welcome to ${BIRed}re:Invent 2017${BIWhite} - Workshop - ${BIRed}GAM310${Color_Off} ........"
echo 
echo -e "## To start, please verify that you have the aws-cli & botocore versions as below (or better). Ignore the OS versions."
echo -e "## Recommended Minimum Versions:"
echo -e "   Windows      : ${IBlue}aws-cli/1.11.185 Python/3.6.2${White} Windows/10 ${IBlue}botocore/1.7.43${Color_Off}"
echo -e "   Linux/Mac OSX: ${IBlue}aws-cli/1.11.187 Python/3.6.2${White} Linux/4.9.51-10.52.amzn1.x86_64 ${IBlue}botocore/1.7.45${Color_Off}"
echo 
echo -e "## Displaying your version below, please visually compare the version...${BIRed}"
aws --version
echo -e "${Color_Off}"
read -p "## Are you good to proceed with the script ('Y')? Respond with 'N' if you want to abort and update. [Y/N]: " userResponse
if [ "$userResponse" = 'N' ] || [ "$userResponse" = 'n' ]; then
	echo "## ABORTED: Please update and restart the script."
	echo 
	exit 1
fi
echo -e "## Setting up your AWS access now."
echo -e "## Provide your Access Key, Secret Key & the Region choice below, for the aws-cli to function correctly."
echo -e "## NOTE: Ensure that you provide 'us-west-2' as the Region and leave the 'Output Format' empty (default/unchanged)..."
aws configure
echo 
echo -e "## Verify below if your AWS configuration has been correctly recorded. Hit CTRL+C to abort now, if it is not set up correctly..."
aws configure list
echo 
echo -e "## Setting up necessary infrastructure for the Workshop..."
echo -e "## Creating and setting up the VPC now..."

IFS=' ' read -ra vpcid <<<$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 | awk '/VpcId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
IFS=' ' read -ra subnetidA <<<$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.1.0/24 --availability-zone us-west-2a | awk '/SubnetId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 modify-subnet-attribute --subnet-id $subnetidA --map-public-ip-on-launch
IFS=' ' read -ra subnetidB <<<$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.2.0/24 --availability-zone us-west-2b | awk '/SubnetId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 modify-subnet-attribute --subnet-id $subnetidB --map-public-ip-on-launch
IFS=' ' read -ra subnetidC <<<$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.3.0/24 --availability-zone us-west-2c | awk '/SubnetId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 modify-subnet-attribute --subnet-id $subnetidC --map-public-ip-on-launch
IFS=' ' read -ra igwid <<<$(aws ec2 create-internet-gateway | awk '/InternetGatewayId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 attach-internet-gateway --vpc-id $vpcid --internet-gateway-id $igwid
IFS=' ' read -ra rtbid <<<$(aws ec2 create-route-table --vpc-id $vpcid | awk '/RouteTableId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 create-route --route-table-id $rtbid --destination-cidr-block 0.0.0.0/0 --gateway-id $igwid
aws ec2 associate-route-table --route-table-id $rtbid --subnet-id $subnetidA 
aws ec2 associate-route-table --route-table-id $rtbid --subnet-id $subnetidB
aws ec2 associate-route-table --route-table-id $rtbid --subnet-id $subnetidC
aws ec2 create-key-pair --key-name myWorkshopKeyPair --query 'KeyMaterial' --output text > ~/myWorkshopKeyPair.pem
chmod 400 ~/myWorkshopKeyPair.pem
IFS=' ' read -ra bastionsgid <<<$(aws ec2 create-security-group --group-name BastionHostAccess --description "Allow access for Bastion Host" --vpc-id $vpcid | awk '/GroupId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 authorize-security-group-ingress --group-id $bastionsgid --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $bastionsgid --protocol tcp --port 80 --cidr 0.0.0.0/0
curl https://s3-us-west-2.amazonaws.com/gam310-2017/iam-base-ec2-policy.json -o iam-base-ec2-policy.json
aws iam create-role --role-name BastionDataGenRole --assume-role-policy-document file://iam-base-ec2-policy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --role-name BastionDataGenRole
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonKinesisFullAccess --role-name BastionDataGenRole
aws iam create-instance-profile --instance-profile-name BastionProfile
aws iam add-role-to-instance-profile --role-name BastionDataGenRole --instance-profile-name BastionProfile

IFS=' ' read -ra redshiftsgid <<<$(aws ec2 create-security-group --group-name RedshiftAccess --description "Allow access for Redshift" --vpc-id $vpcid | awk '/GroupId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 authorize-security-group-ingress --group-id $redshiftsgid --protocol tcp --port 5439 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $redshiftsgid --protocol tcp --port 8192 --cidr 0.0.0.0/0

IFS=' ' read -ra bastioninstanceid <<<$(aws ec2 run-instances --image-id ami-7f2afa07 --count 1 --instance-type t2.micro --key-name myWorkshopKeyPair --security-group-ids $bastionsgid --subnet-id $subnetidA | awk '/InstanceId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
IFS=' ' read -ra bastionpublicip <<<$(aws ec2 describe-instances --instance-id $bastioninstanceid --query 'Reservations[*].Instances[*].PublicIpAddress' --output=text)
aws ec2 associate-iam-instance-profile --instance-id $bastioninstanceid --iam-instance-profile Name=BastionProfile

echo -e "## Make a note of your infrastructure IDs. Its recommended that you copy them to a text editor, for future reference through the workshop:"
echo -e "   VPC ID in us-west-2  : $vpcid"
echo -e "   Subnet in us-west-2a : $subnetidA"
echo -e "   Subnet in us-west-2b : $subnetidB"
echo -e "   Subnet in us-west-2c : $subnetidC"
echo -e "   Internet Gateway ID  : $igwid"
echo -e "   Route Table ID       : $rtbid"
echo -e "   Subnets & their CIDRs: "
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcid" --query 'Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock,MapPublicIP:MapPublicIpOnLaunch}'
echo -e "   Bastion Instance ID  : $bastioninstanceid"
echo -e "   Bastion Public IP    : $bastionpublicip"
echo 
echo -e "## Pausing 60 seconds for the instance to be created and initialized properly."
echo -e "## We will then initiating SSH to your new Bastion instance..."
echo 
sleep 60
echo -e "ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip"
ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip