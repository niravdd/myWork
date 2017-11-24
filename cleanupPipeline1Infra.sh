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
echo -e "${On_Blue}${BIRed}      #.  C L E A N - U P    I N F R A S T R U C T U R E       ${Color_Off}"
echo 
echo 
echo -e "## ${BIWhite}Action Required:${BIRed}"
echo -e "## Do note, its *should not* be a problem if you run this script multiple times, just make sure you run it only when you are ready to clean-up."
read -n 1 -p "## Are you good to proceed with the clean-up (any key)? Respond with 'N' if you want to abort and update. [Y/N]: " userResponse
echo -e "${Color_Off}"
if [ "$userResponse" = 'N' ] || [ "$userResponse" = 'n' ]; then
	echo "## ABORTED: Please re-run the script whenever you're ready to clean-up the infrastructure."
	echo 
	exit 1
fi
echo 
echo -e "## All good! Deleting everything created from this host now..."
## Cleanup...
# aws redshift delete-cluster --cluster-identifier workshopcluster --skip-final-cluster-snapshot
# echo -e "## Waiting for the Redshift Cluster to be deleted before proceeding..."
# echo -ne "## ${Blue}Checking${Color_Off} ="
# ## Can also use http://docs.aws.amazon.com/cli/latest/reference/redshift/wait/cluster-available.html here - but prefer to use own, so -
# IFS=' ' read -ra testCondition <<<$(aws redshift describe-clusters --cluster-identifier workshopcluster --query 'Clusters[*].ClusterStatus' --output text)
# nCounter=0
# while [ "$testCondition" = "deleting" ];
# do
# 	if [ "$nCounter" -lt "60" ]; then
# 		echo -ne "="
# 	else
# 		echo -ne "o"
# 		nCounter=0
# 		IFS=' ' read -ra testCondition <<<$(aws redshift describe-clusters --cluster-identifier workshopcluster --query 'Clusters[*].ClusterStatus' --output text)
# 		continue
# 	fi
# 	nCounter=$[$nCounter+5]
# 	sleep 5
# done
# echo -ne " ${Red}[Deleted!]${Color_Off}"
# echo 

# aws redshift delete-cluster-subnet-group --cluster-subnet-group-name workshopsubnetgroup
# aws ec2 delete-security-group --group-id varRedshiftsgid
aws s3 rb s3://varBucketName --force
# aws iam delete-role-policy --role-name redshift_fullaccess_role --policy-name iam-redshift-policy
# aws iam delete-role --role-name redshift_fullaccess_role
aws iam delete-role-policy --role-name wsfirehose_delivery_role --policy-name iam-fh-policy --region us-west-2
aws iam delete-role --role-name wsfirehose_delivery_role --region us-west-2
aws iam delete-role-policy --role-name kinesisanalytics_delivery_role --policy-name iam-ka-policy --region us-west-2
aws iam delete-role --role-name kinesisanalytics_delivery_role --region us-west-2
aws logs delete-log-group --log-group-name "/aws/kinesisanalytics/workshopTelemetryKAApp" --region us-west-2
aws logs delete-log-group --log-group-name "/aws/kinesisfirehose/workshopTelemetryFHDirect" --region us-west-2
aws logs delete-log-group --log-group-name "/aws/kinesisfirehose/workshopTelemetryFH" --region us-west-2
aws logs delete-log-group --log-group-name "/aws/kinesisfirehose/workshopAnalyticsFH" --region us-west-2
IFS=' ' read -ra appCreateTime <<<$(aws kinesisanalytics describe-application --application-name workshopTelemetryKAApp --query 'ApplicationDetail.CreateTimestamp' --output text)
aws kinesisanalytics delete-application --application-name workshopTelemetryKAApp --create-timestamp $appCreateTime --region us-west-2
aws firehose delete-delivery-stream --delivery-stream-name workshopTelemetryFHDirect --region us-west-2
aws firehose delete-delivery-stream --delivery-stream-name workshopTelemetryFH --region us-west-2
aws firehose delete-delivery-stream --delivery-stream-name workshopAnalyticsFH --region us-west-2
aws kinesis delete-stream --stream-name workshopTelemetryStream --region us-west-2
aws kinesis delete-stream --stream-name workshopAnalyticsStream --region us-west-2
## ... End }