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

## { Start...
echo -e "........ ${BIWhite}Welcome to ${BIRed}re:Invent 2017${BIWhite} - Workshop - ${BIRed}GAM310${Color_Off} ........"
echo -e "${On_Blue}${BIRed}           0.  P R E R E Q U I S I T E S    &    S E T U P     ${Color_Off}"
echo 
echo -e "## To start, please verify that you have the aws-cli & botocore versions as below (or better). Ignore the OS versions."
echo -e "## Recommended Minimum Versions:"
echo -e "   Windows      : ${IBlue}aws-cli/1.11.185 Python/3.6.2${White} Windows/10 ${IBlue}botocore/1.7.43${Color_Off}"
echo -e "   Linux/Mac OSX: ${IBlue}aws-cli/1.11.187 Python/3.6.2${White} Linux/4.9.51-10.52.amzn1.x86_64 ${IBlue}botocore/1.7.45${Color_Off}"
echo 
echo -e "## ${BIWhite}Action Required:${Color_Off} Displaying your version below, please visually compare the version...${IBlue}"
aws --version
echo -e "{$Color_Off}"
echo -e "## ${BIWhite}Action Required:${Color_Off}"
read -n 1 -p "## Are you good to proceed with the script (any key)? Respond with 'N' if you want to abort and update. [Y/N]: " userResponse
echo 
if [ "$userResponse" = 'N' ] || [ "$userResponse" = 'n' ]; then
	echo "## ABORTED: Please update and restart the script."
	echo 
	exit 1
fi
echo 
echo -e "## All good then. Setting up your AWS access configuration now..."
echo -e "## ${BIWhite}Action Required:${Color_Off} Provide your Access Key, Secret Key & the Region choice below, for the aws-cli to function correctly."
echo -e "## NOTE: Ensure that you provide '${BIPurple}us-west-2${Color_Off}' as the Region and leave the 'Output Format' empty (default/unchanged)...${IRed}"
aws configure
echo -e "${Color_Off}"
echo -e "## ${BIWhite}Action Required:${Color_Off} Review below if your AWS configuration has been correctly recorded. Hit CTRL+C to abort now... ${BIRed}"
aws configure list
echo -e "${Color_Off}"
echo -e "## ${BIWhite}Action Required:${Color_Off}"
read -n 1 -s -r -p "Press any key to continue... Hit CTRL+C to abort now..."
echo 
echo -e "## Setting up necessary infrastructure for the Workshop..."
echo -e "## Creating and setting up the VPC now..."

IFS=' ' read -ra vpcid <<<$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 | awk '/VpcId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
echo -e "## Creating the subnets in the VPC now..."
IFS=' ' read -ra subnetidA <<<$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.1.0/24 --availability-zone us-west-2a | awk '/SubnetId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 modify-subnet-attribute --subnet-id $subnetidA --map-public-ip-on-launch
IFS=' ' read -ra subnetidB <<<$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.2.0/24 --availability-zone us-west-2b | awk '/SubnetId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 modify-subnet-attribute --subnet-id $subnetidB --map-public-ip-on-launch
IFS=' ' read -ra subnetidC <<<$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.3.0/24 --availability-zone us-west-2c | awk '/SubnetId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 modify-subnet-attribute --subnet-id $subnetidC --map-public-ip-on-launch
echo -e "## Creating the internet gateway in the VPC now..."
IFS=' ' read -ra igwid <<<$(aws ec2 create-internet-gateway | awk '/InternetGatewayId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 attach-internet-gateway --vpc-id $vpcid --internet-gateway-id $igwid
echo -e "## Creating the route table in the VPC now..."
IFS=' ' read -ra rtbid <<<$(aws ec2 create-route-table --vpc-id $vpcid | awk '/RouteTableId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 create-route --route-table-id $rtbid --destination-cidr-block 0.0.0.0/0 --gateway-id $igwid
echo -e "## Associating the route table with the subnets now..."
aws ec2 associate-route-table --route-table-id $rtbid --subnet-id $subnetidA 
aws ec2 associate-route-table --route-table-id $rtbid --subnet-id $subnetidB
aws ec2 associate-route-table --route-table-id $rtbid --subnet-id $subnetidC
echo -e "## Creating a key pair for you now... Please find ~/myWorkshopKeyPair.pem"
aws ec2 create-key-pair --key-name myWorkshopKeyPair --query 'KeyMaterial' --output text > ~/myWorkshopKeyPair.pem
chmod 400 ~/myWorkshopKeyPair.pem
echo -e "## Creating the security groups required..."
IFS=' ' read -ra bastionsgid <<<$(aws ec2 create-security-group --group-name BastionHostAccess --description "Allow access for Bastion Host" --vpc-id $vpcid | awk '/GroupId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 authorize-security-group-ingress --group-id $bastionsgid --protocol tcp --port 22 --cidr 0.0.0.0/0

echo -e "## Creating the Bastion host instance now..."
IFS=' ' read -ra bastioninstanceid <<<$(aws ec2 run-instances --image-id ami-7f2afa07 --count 1 --instance-type t2.micro --key-name myWorkshopKeyPair --security-group-ids $bastionsgid --subnet-id $subnetidA | awk '/InstanceId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
echo -e "## Pausing 30 seconds for the instance to be created..."
sleep 30
IFS=' ' read -ra bastionpublicip <<<$(aws ec2 describe-instances --instance-id $bastioninstanceid --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
echo 
echo -e "## ${BIWhite}Action Required:${Color_Off} Make a note of your infrastructure listed below."
echo -e "## Its recommended that you copy them to a text editor, for future reference through the workshop:"
echo -e "   VPC ID in us-west-2  : ${BIWhite}$vpcid${Color_Off}"
echo -e "   Subnet in us-west-2a : ${BIWhite}$subnetidA${Color_Off}"
echo -e "   Subnet in us-west-2b : ${BIWhite}$subnetidB${Color_Off}"
echo -e "   Subnet in us-west-2c : ${BIWhite}$subnetidC${Color_Off}"
echo -e "   Internet Gateway ID  : ${BIWhite}$igwid${Color_Off}"
echo -e "   Route Table ID       : ${BIWhite}$rtbid${Color_Off}"
echo 
echo -e "   Bastion Instance ID  : ${BIWhite}$bastioninstanceid${Color_Off}"
echo -e "   Bastion Public IP    : ${BIWhite}$bastionpublicip${Color_Off}"
echo 
echo -e "   Subnets & their CIDRs: "
echo -e "${BIWhite}AZ\t\tCIDR Blocks\tSubnet ID\tMap Public IP on Launch?${Color_Off}"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcid" --query 'Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock,MapPublicIP:MapPublicIpOnLaunch}' --output text
echo 

sed -i -- "s/varBastionInstanceID/$bastioninstanceid/g" cleanupBaseInfra.sh
sed -i -- "s/varBastionsgid/$bastionsgid/g" cleanupBaseInfra.sh
sed -i -- "s/varSubnetidA/$subnetidA/g" cleanupBaseInfra.sh
sed -i -- "s/varSubnetidB/$subnetidB/g" cleanupBaseInfra.sh
sed -i -- "s/varSubnetidC/$subnetidC/g" cleanupBaseInfra.sh
sed -i -- "s/varRTBid/$rtbid/g" cleanupBaseInfra.sh
sed -i -- "s/varIGWid/$igwid/g" cleanupBaseInfra.sh
sed -i -- "s/varVPCid/$vpcid/g" cleanupBaseInfra.sh

echo -e "## Pausing 30 more seconds for the instance to be created and initialized properly."
echo -e "## We will then initiate SSH'ing to your new Bastion instance..."
echo 
sleep 30
echo -e "ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip"
ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip

## while true;
## do
## 	echo 
## 	echo -e "## ${BIWhite}Action Required:${Color_Off}"
## 	echo -e "## Script will now initiate a clean-up of your infrastructure, if you are done with your work..."
## 	read -n 1 -p "## Are you good to proceed with the script (any key)? Respond with 'N' if you want to get back into your Bastion host. [Y/N]: " userResponse
## 	echo 
## 	if [ "$userResponse" = 'N' ] || [ "$userResponse" = 'n' ]; then
## 		echo -e "ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip"
## 		ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip 
## 	else
## 		echo -e "## ${BIWhite}Action Required:${Color_Off}"
## 		echo -e "## Are you sure? The script will now delete all the infrastructure."
## 		read -n 1 -p "## Are you good to proceed with the clean-up (any key)? Last chance to respond with 'N' if you want to get back into your Bastion host. [Y/N]: " userResponse
## 		echo 
## 		if [ "$userResponse" = 'N' ] || [ "$userResponse" = 'n' ]; then
## 			echo -e "ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip"
## 			ssh -i ~/myWorkshopKeyPair.pem ec2-user@$bastionpublicip
## 			continue
## 		fi
## 		break
## 	fi
## done

## Cleanup...
## aws ec2 delete-security-group --group-id $bastionsgid
## aws ec2 delete-subnet --subnet-id $subnetidA
## aws ec2 delete-subnet --subnet-id $subnetidB
## aws ec2 delete-subnet --subnet-id $subnetidC
## aws ec2 delete-route-table --route-table-id $rtbid
## aws ec2 detach-internet-gateway --internet-gateway-id $igwid --vpc-id $vpcid
## aws ec2 delete-internet-gateway --internet-gateway-id $igwid
## aws ec2 delete-vpc --vpc-id $vpcid

## ... End }