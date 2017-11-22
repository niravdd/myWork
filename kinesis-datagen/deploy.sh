# Update the bucket name if needed - make sure that you have the adequate rights to put files into that bucket 
# (check ec2instance role or your laptop local credentials)
BUCKETNAME="gam310-2017"

BASEDIR=$(dirname "$0")
cd $BASEDIR"/../"
tar -cvf /tmp/kinesis-datagen.tar kinesis-datagen/

cd kinesis-datagen/
#aws s3 cp $BASEDIR"/kinesis-datagen-cfn.json" "s3://"$BUCKETNAME"/kinesis-datagen-cfn.json"
aws s3 cp /tmp/kinesis-datagen.tar "s3://"$BUCKETNAME"/kinesis-datagen.tar" --acl public-read
