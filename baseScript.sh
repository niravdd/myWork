## Started writing this as a BAT file, however - will convert it to a bash script
##

@Echo Off
Echo "Welcome to re:Invent 2017 - Workshop - Session GAM310"
Echo.
Echo "To start, please check that you have the AWS CLI version as below (or better)..."
Echo "Recommended Minimum Version => aws-cli/1.11.185 Python/3.6.2 Windows/10 botocore/1.7.43"
Echo "Checking version..."
aws --version
timeout /t 10
Echo "Provide your Access Key and Secret Key for the CLI access..."
Echo "NOTE: Ensure that you provide 'us-west-2' as the Region and leave the Output Format empty..."
aws configure
Echo "Check if your configuration has been correctly recorded & setup... Hit CTRL+C now, if it is not set up correctly..."
aws configure list
timeout /t 15

Echo "Setting up necessary infrastructure for the Workshop..."

aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query Vpcs[*].VpcId > tempFile.txt
