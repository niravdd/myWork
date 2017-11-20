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
echo -e "${On_Blue}${BIRed}           1.  A N A L Y T I C S'   P I P E L I N E            ${Color_Off}\n\n"
echo -e "## ${BIWhite}Action Required:${Color_Off}"
echo -e "## Please ensure you have run the ${BIBlue}baseInfraScript.sh${Color_Off} prior to starting this - else this script will encounter failures.\n\n"
read -n 1 -p "## Are you good to proceed with this script (any key)? Respond with 'N' if you want to abort and update. [Y/N]: " userResponse
if [ "$userResponse" = 'N' ] || [ "$userResponse" = 'n' ]; then
	echo -e "\n\n## ${BIRed}ABORTED${Color_Off}: Please update and restart the script.\n\n"
	exit 1
fi
echo -e "\n\n## ${Green}All good then.${Color_Off} Setting up your AWS access on this Bastion Host now...\n\n"
echo -e "## ${BIWhite}Action Required:${Color_Off} Provide your Access Key, Secret Key & the Region choice below, for the aws-cli to function correctly."
echo -e "## NOTE: Ensure that you provide '${BIPurple}us-west-2${Color_Off}' as the Region and leave the 'Output Format' empty (default/unchanged)...${IRed}"
aws configure
echo -e "${Color_Off}\n\n"
echo -e "## ${BIWhite}Action Required:${Color_Off} Review below if your AWS configuration has been correctly recorded. Hit CTRL+C to abort now... ${IBlue}"
aws configure list
echo -e "${Color_Off}\n\n"
echo -e "## ${BIWhite}Action Required:${Color_Off}"
read -n 1 -s -r -p "Press any key to continue... Hit CTRL+C to abort now..."

echo -e "\n\n## ${Green}Great.${Color_Off} Pull out that text editor where you stored the infra IDs."
echo -e "\n\n## ${BIWhite}Action Required:${Color_Off}"
echo -e "## Please provide the info we created and recorded in the previous script below:${BIRed}"
read -p "   VPC ID in us-west-2 : " vpcid
read -p "   Subnet in us-west-2a: " subnetidA
read -p "   Subnet in us-west-2b: " subnetidB
read -p "   Subnet in us-west-2c: " subnetidC
echo -e "${Color_Off}\n\n"
echo -e "## ${BIGreen}Thank you!${Color_Off}\n\n"
echo -e "   Review the subnets & their CIDRs in your VPC for the workshop:"
echo -e "${BIWhite}AZ\t\tCIDR Blocks\tSubnet ID\tMap Public IP on Launch?${IBlue}"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcid" --query 'Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock,MapPublicIP:MapPublicIpOnLaunch}' --output text

echo -e "${Color_Off}\n\n## Starting setting up the infrastructure for the first pipeline..."
IFS=' ' read -ra accountid <<<$(aws sts get-caller-identity --query "Account" --output text)
bucketname=workshop-data-${accountid}
echo -e "## Creating a bucket in Amazon S3 - \'${BIPurple}$bucketname${Color_Off}\'..."
aws s3api create-bucket --bucket $bucketname --acl private --create-bucket-configuration LocationConstraint=us-west-2

echo -e "## Preparing the ${BIBlue}cleanupPipeline1Infra.sh${Color_Off} & required ${BIBlue}*.json{Color_Off} dependencies..."
sed -i -- "s/varAccountID/$accountid/g" *.json
sed -i -- "s/varBucketName/$bucketname/g" *.json
sed -i -- "s/varBucketName/$bucketname/g" cleanupPipeline1Infra.sh

echo -e "## Creating the roles now..."
aws iam create-role --role-name redshift_fullaccess_role --assume-role-policy-document file://iam-base-redshift-policy.json
aws iam put-role-policy --role-name redshift_fullaccess_role --policy-name iam-redshift-policy --policy-document file://iam-redshift-policy.json

aws iam create-role --role-name firehose_delivery_role --assume-role-policy-document file://iam-base-fh-policy.json
aws iam put-role-policy --role-name firehose_delivery_role --policy-name iam-fh-policy --policy-document file://iam-fh-policy.json

aws iam create-role --path /service-role/ --role-name kinesisanalytics_delivery_role --assume-role-policy-document file://iam-base-ka-policy.json
aws iam put-role-policy --role-name kinesisanalytics_delivery_role --policy-name iam-ka-policy --policy-document file://iam-ka-policy.json

echo -e "## Creating the security groups now..."
IFS=' ' read -ra redshiftsgid <<<$(aws ec2 create-security-group --group-name RedshiftAccess --description "Allow access for Redshift" --vpc-id $vpcid | awk '/GroupId/{ gsub(/,/, "", $2); gsub(/"/, "", $2); print $2; }')
aws ec2 authorize-security-group-ingress --group-id $redshiftsgid --protocol tcp --port 5439 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $redshiftsgid --protocol tcp --port 8192 --cidr 0.0.0.0/0

echo -e "## Updating the ${BIBlue}cleanupPipeline1Infra.sh${Color_Off}..."
sed -i -- "s/varRedshiftsgid/$redshiftsgid/g" cleanupPipeline1Infra.sh

echo -e "## Creating the Redshift Cluster now..."
aws redshift create-cluster-subnet-group --cluster-subnet-group-name workshopsubnetgroup --description "My subnet group for the workshop" --subnet-ids $subnetidA $subnetidB $subnetidC
aws redshift create-cluster --cluster-identifier workshopcluster --master-username wsuser --master-user-password wsPassword0 --cluster-type single-node --node-type ds2.xlarge --cluster-type single-node --db-name workshopdb --cluster-subnet-group-name workshopsubnetgroup --vpc-security-group-ids $redshiftsgid

echo -e "## Waiting for the Redshift Cluster to be created & be ready for use..."
echo -ne "## ${Blue}Checking${Color_Off} ="
## Can also use http://docs.aws.amazon.com/cli/latest/reference/redshift/wait/cluster-available.html here - but prefer to use own, so -
testCondition="creating"
nCounter=0
while [ "$testCondition" != "available" ];
do
	if [ "$nCounter" -lt "60" ]; then
		echo -ne "="
	else
		echo -ne "o"
		nCounter=0
		IFS=' ' read -ra testCondition <<<$(aws redshift describe-clusters --cluster-identifier workshopcluster --query 'Clusters[*].ClusterStatus' --output text)
		continue
	fi
	nCounter=$[$nCounter+5]
	sleep 5
done
echo -ne " ${Green}[Available now!]${Color_Off}\n\n"

IFS=' ' read -ra redshiftClusterEndpoint <<<$(aws redshift describe-clusters --cluster-identifier workshopcluster --query 'Clusters[*].Endpoint.Address' --output text)
IFS=' ' read -ra redshiftClusterPort <<<$(aws redshift describe-clusters --cluster-identifier workshopcluster --query 'Clusters[*].Endpoint.Port' --output text)

echo -e "## Updating the ${BIBlue}cleanupPipeline1Infra.sh${Color_Off}..."
sed -i -- "s/varRedshiftClusterEndpoint/$redshiftClusterEndpoint/g" *.json
sed -i -- "s/varRedshiftClusterEndpoint/$redshiftClusterEndpoint/g" connectRedshift.sh
sed -i -- "s/5439/$redshiftClusterPort/g" *.json
sed -i -- "s/5439/$redshiftClusterPort/g" connectRedshift.sh

echo -e "\n\n## ${BIWhite}Action Required:${Color_Off}"
echo -e "## ${Red}The script will now launch pgcli (client) connected to your Redshift Cluster.${Color_Off}"
echo -e "## Please run each of the following commands at the pgcli prompt one at a time.${Color_Off}"
echo -e "\n${BIRed}First run:${BICyan}"
echo -e "create table analytics1 (playerip varchar(16), handle varchar(40), email varchar(128), uuid varchar(64), playerid bigint, country varchar(64), useragent varchar(128), datestamp timestamptz, walletbalance real, playerlevel varchar(16), status varchar(16));"
echo -e "${BIRed}\n... then run:${BICyan}"
echo -e "create table telemetry1 (datestamp timestamptz, playerid bigint, playerlevel varchar(16), squadelementmap varchar(8), gamenumber int, squadpower int, squadagility int, squadhealth int, squadluck int, squadspecial int, squadguard int, squaddamage int, squadinventoryitemcount int, bosspower int, bossagility int, bosshealth int, bossluck int, bossspecial int, bossguard int, bossdamage int, result varchar(8));"
echo -e "${BIRed}\n... then, finally run:${BICyan}"
echo -e "create table telemetry2 (datestamp timestamptz, playerid bigint, playerlevel varchar(16), squadelementmap varchar(8), gamenumber int, squadpower int, squadagility int, squadhealth int, squadluck int, squadspecial int, squadguard int, squaddamage int, squadinventoryitemcount int, bosspower int, bossagility int, bosshealth int, bossluck int, bossspecial int, bossguard int, bossdamage int, result varchar(8));"
echo -e "${BIRed}\n... to quit, issue the command ${BICyan}quit${BIRed} whenever you are done.${Color_Off}\n\n"
echo -e "## Launching the pgcli (Redshift Client) now... ${Yellow}\n"
sh ./connectRedshift.sh

echo -e "\n\n## ${Green}Great job there!${Color_Off} Proceeding...\n"
echo -e "## Creating the Kinesis Streams now..."
echo -e "## Analytics' Stream..."
## Create your Kinesis stream for analytics
aws kinesis create-stream --stream-name workshopAnalyticsStream --shard-count 10
sleep 15
echo -e "## Telemetry Stream..."
## Create your Kinesis stream for telemtry
aws kinesis create-stream --stream-name workshopTelemetryStream --shard-count 10
sleep 15

echo -e "## Creating the Kinesis Firehose Streams now..."
## Create a log group and streams for analytics
aws logs create-log-group  --log-group-name "/aws/kinesisfirehose/workshopAnalyticsFH"
aws logs create-log-stream --log-group-name "/aws/kinesisfirehose/workshopAnalyticsFH" --log-stream-name "S3Delivery"
aws logs create-log-stream --log-group-name "/aws/kinesisfirehose/workshopAnalyticsFH" --log-stream-name "RedshiftDelivery"

## Create a log group and streams for telemetry
aws logs create-log-group  --log-group-name "/aws/kinesisfirehose/workshopTelemetryFH"
aws logs create-log-stream --log-group-name "/aws/kinesisfirehose/workshopTelemetryFH" --log-stream-name "S3Delivery"
aws logs create-log-stream --log-group-name "/aws/kinesisfirehose/workshopTelemetryFH" --log-stream-name "RedshiftDelivery"

## Create a log group and streams for telemetry - direct stream
aws logs create-log-group  --log-group-name "/aws/kinesisfirehose/workshopTelemetryFHDirect"
aws logs create-log-stream --log-group-name "/aws/kinesisfirehose/workshopTelemetryFHDirect" --log-stream-name "S3Delivery"
aws logs create-log-stream --log-group-name "/aws/kinesisfirehose/workshopTelemetryFHDirect" --log-stream-name "RedshiftDelivery"

## Create a log group and streams for Kinesis Analytics' App
aws logs create-log-group  --log-group-name "/aws/kinesisanalytics/workshopTelemetryKAApp"
aws logs create-log-stream --log-group-name "/aws/kinesisanalytics/workshopTelemetryKAApp" --log-stream-name "AppDelivery"

echo -e "## Analytics' Firehose Stream..."
sleep 15
aws firehose create-delivery-stream --delivery-stream-name workshopAnalyticsFH --delivery-stream-type KinesisStreamAsSource --kinesis-stream-source-configuration "KinesisStreamARN=arn:aws:kinesis:us-west-2:${accountid}:stream/workshopAnalyticsStream,RoleARN=arn:aws:iam::${accountid}:role/firehose_delivery_role" --cli-input-json file://analytics1Input.json
echo -e "## Telemetry(1) Firehose Stream..."
sleep 15
aws firehose create-delivery-stream --delivery-stream-name workshopTelemetryFH --delivery-stream-type KinesisStreamAsSource --kinesis-stream-source-configuration "KinesisStreamARN=arn:aws:kinesis:us-west-2:${accountid}:stream/workshopTelemetryStream,RoleARN=arn:aws:iam::${accountid}:role/firehose_delivery_role" --cli-input-json file://telemetry1Input.json
echo -e "## Telemetry(2) Firehose Stream..."
sleep 15
aws firehose create-delivery-stream --delivery-stream-name workshopTelemetryFHDirect --delivery-stream-type DirectPut --cli-input-json file://telemetry2Input.json
sleep 30
echo -e "## Setting up Kinesis Analytics App now..."
aws kinesisanalytics create-application --application-name workshopTelemetryKAApp --cli-input-json file://kinesisAnalyticsInput.json
sleep 30
aws kinesisanalytics start-application --application-name workshopTelemetryKAApp --input-configuration Id="1.1",InputStartingPositionConfiguration={InputStartingPosition="NOW"}

echo -e "\n\n## ${On_Green}${BIYellow}There, All Done! We will use all these for Pipelines 1, 2 & 3!${Color_Off}\n\n"

## ... End }