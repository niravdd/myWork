# Update the bucket name if needed - make sure that you have the adequate rights to put files into that bucket 
# (check ec2instance role or your laptop local credentials)
BUCKETNAME="gam310-2017"

tar -cvf /tmp/kinesis-datagen.tar kinesis-datagen/

aws s3 cp /tmp/kinesis-datagen.tar "s3://"$BUCKETNAME"/kinesis-datagen.tar" --acl public-read
aws s3 cp gam310-workshop-cfn.yml "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp iam-base-ec2-policy.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp iam-base-fh-policy.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp iam-base-ka-policy.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp iam-fh-policy.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp iam-ka-policy.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp analytics1Input.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp telemetry1Input.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp telemetry2Input.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp kinesisAnalyticsInput.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp pipeline1Script.sh "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp cleanupPipeline1Infra.sh "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp connectRedshift.sh "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website "s3://"$BUCKETNAME"/" --acl public-read --recursive
