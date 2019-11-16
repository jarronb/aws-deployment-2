#! /bin/bash
name=$USER
aws_region="$(cat ~/.aws/config | grep region | head -1 | sed -e 's/^\s*//' -e '/^$/d' | cut -d '=' -f 2 | sed -e 's/^\s*//' -e '/^$/d')"
ec2_key_name="$(aws ec2 describe-key-pairs | cut -f 3 | head -1)"
aws_ec2_instance_profile="$(aws --output text --query "InstanceProfiles[0].InstanceProfileName" iam list-instance-profiles)"

# Get variables
read -ep "Name [${name}]: " NAME
NAME=${NAME:-${name}}

read -ep "AWS EC2 IAM Instance Profile [${aws_ec2_instance_profile}]: " AWS_EC2_INSTANCE_PROFILE
AWS_EC2_INSTANCE_PROFILE=${AWS_EC2_INSTANCE_PROFILE:-${aws_ec2_instance_profile}}

read -ep "AWS region [${aws_region}]: " AWS_REGION
AWS_REGION=${AWS_REGION:-${aws_region}}

read -ep "Database name [${NAME}itmo444database]: " DYNAMO_DB_NAME
DYNAMO_DB_NAME=${DYNAMO_DB_NAME:-${NAME}itmo444database}

read -ep "EC2 key pair[${ec2_key_name}]: " EC2_KEY_NAME
EC2_KEY_NAME=${EC2_KEY_NAME:-${ec2_key_name}}

USER_DATA_FILE_PATH="./install-app-env.sh"
USER_DATA_FILE_PATH2="./install-app-poller-env.sh"

# Save varibles in temp file
cat <<EOT > ./varaibles.txt
#!/bin/bash

# Application Variables
NAME="$NAME"
AWS_EC2_INSTANCE_PROFILE="$AWS_EC2_INSTANCE_PROFILE"
AWS_REGION="$AWS_REGION"
EC2_KEY_NAME="$EC2_KEY_NAME"
EC2_IMAGE="ami-02ea09b6148bc4a49"
USER_DATA_FILE_PATH="$USER_DATA_FILE_PATH"
USER_DATA_FILE_PATH2="$USER_DATA_FILE_PATH2"
ELB_NAME="${NAME}itmo444elb"
S3_BUCKET_RAW_IMAGE="${NAME}-itmo444-midterm-raw-image-bucket"
S3_BUCKET_POST_IMAGE="${NAME}-itmo444-midterm-post-image-bucket"
SECURITY_GROUP_NAME="${NAME}itmo444sg"
DYNAMO_DB_NAME="$DYNAMO_DB_NAME"
SQS_NAME="${NAME}itmo444sqs"
OUTPUT_DIR=../aws-output/

EOT

export AWS_DEFAULT_OUTPUT="text"

# Add variables to create-env.sh
cat ./varaibles.txt ./templates/create-env.sh > ./create-env.sh

# Add variables to install-app.sh
cat ./varaibles.txt ./templates/install-app-env.sh > ./install-app-env.sh

# Add variables to install-app-poller-env.sh
cat ./varaibles.txt ./templates/install-app-poller-env.sh > ./install-app-poller-env.sh

# Add variables to destroy.sh
cat ./varaibles.txt ./templates/destroy-env.sh > ./destroy-env.sh

# Remove temp varibles
rm -f ./varaibles.txt

# Run create environment
echo " "
echo "Creating environmet..."
echo " "

bash create-env.sh