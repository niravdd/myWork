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
aws s3 cp analytics1Input.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp telemetry1Input.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp telemetry2Input.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp kinesisAnalyticsInput.json "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/index.html "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/1.html "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/2.html "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/3.html "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/4.html "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/Pipeline1.png "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/Pipeline2.png "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/Pipeline3.png "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/Pipeline4.png "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/style.css "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/gam310.js "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/gam310WorkshopHelp.js "s3://"$BUCKETNAME"/" --acl public-read
aws s3 cp Website/gam310WorkshopUpdate.js "s3://"$BUCKETNAME"/" --acl public-read
