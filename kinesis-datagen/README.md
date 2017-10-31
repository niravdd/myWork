## Requirements

In order to run, make sure to have the following : 

- Create an S3 bucket
- Update the bucketName in the deploy.sh script
- Use the deploy.sh script to deploy the code into S3 - this will also copy the cloudformation.json file there  
- Create a Kinesis Stream (remember its name, it will be needed in the webconsole)
- To use the cloudformation stack, create a role which can read from the S3 bucket which contains the zipped code and that can push to the Kinesis stream

## Usage

Create a new cloudformation stack using the cloudformation.json file (which should be in the s3 bucket that you created previously). 
The cloudformation script will install php7, apache and deploy the code on the ec2 instance. 
Check the output to get the link of the web page. For example : http://ec2-34-22-91-12.compute-1.amazonaws.com/kinesis-datagen

The code will attempt to use the ec2 instance role assigned to it. So, again, make sure that the role can push to the Kinesis Stream that you created earlier !

For the web console, use index.php.

You can also use the command line script generate.php.

If you want to run this locally (e.g. on your laptop), make sure to create a config/credentials.php file (use the sample as an example). Provide the adequate access key and secret. You will have to install PHP7+ and apache.

## Keep in mind

Deploying and executing the code on an ec2 instance will provide the best performance (lower latency to push to Kinesis).
Speed will also depend on the number of shards that you have defined for the kinesis stream.
